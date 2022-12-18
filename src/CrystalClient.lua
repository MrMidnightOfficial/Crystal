--[=[
	@interface Middleware
	.Inbound ClientMiddleware?
	.Outbound ClientMiddleware?
	@within CrystalClient
]=]
type Middleware = {
	Inbound: ClientMiddleware?,
	Outbound: ClientMiddleware?,
}

--[=[
	@type ClientMiddlewareFn (args: {any}) -> (shouldContinue: boolean, ...: any)
	@within CrystalClient

	For more info, see [ClientComm](https://sleitnick.github.io/RbxUtil/api/ClientComm/) documentation.
]=]
type ClientMiddlewareFn = (args: {any}) -> (boolean, ...any)

--[=[
	@type ClientMiddleware {ClientMiddlewareFn}
	@within CrystalClient
	An array of client middleware functions.
]=]
type ClientMiddleware = {ClientMiddlewareFn}

--[=[
	@type PerServiceMiddleware {[string]: Middleware}
	@within CrystalClient
]=]
type PerServiceMiddleware = {[string]: Middleware}

--[=[
	@interface ControllerDef
	.Name string
	.[any] any
	@within CrystalClient
	Used to define a controller when creating it in `CreateController`.
]=]
type ControllerDef = {
	Name: string,
	[any]: any,
}

--[=[
	@interface Controller
	.Name string
	.[any] any
	@within CrystalClient
]=]
type Controller = {
	Name: string,
	[any]: any,
}

--[=[
	@interface Service
	.[any] any
	@within CrystalClient
]=]
type Service = {
	[any]: any,
}

--[=[
	@interface CrystalOptions
	.ServicePromises boolean?
	.Middleware Middleware?
	.PerServiceMiddleware PerServiceMiddleware?
	@within CrystalClient

	- `ServicePromises` defaults to `true` and indicates if service methods use promises.
	- Each service will go through the defined middleware, unless the service
	has middleware defined in `PerServiceMiddleware`.
]=]
type CrystalOptions = {
	ServicePromises: boolean,
	Middleware: Middleware?,
	PerServiceMiddleware: PerServiceMiddleware?,
}

local defaultOptions: CrystalOptions = {
	ServicePromises = true,
	Middleware = nil,
	PerServiceMiddleware = {},
}

local selectedOptions = nil


--[=[
	@class CrystalClient
	@client
]=]
local CrystalClient = {}

--[=[
	@prop Player Player
	@within CrystalClient
	@readonly
	Reference to the LocalPlayer.
]=]
CrystalClient.Player = game:GetService("Players").LocalPlayer

--[=[
	@prop Util Folder
	@within CrystalClient
	@readonly
	References the Util folder. Should only be accessed when using Crystal as
	a standalone module. If using Crystal from Wally, modules should just be
	pulled in via Wally instead of relying on Crystal's Util folder, as this
	folder only contains what is necessary for Crystal to run in Wally mode.
]=]
CrystalClient.Util = script.Parent.Parent

local Promise = require(CrystalClient.Util.Promise)
local Comm = require(CrystalClient.Util.Comm)
local ClientComm = Comm.ClientComm

local controllers: {[string]: Controller} = {}
local services: {[string]: Service} = {}
local servicesFolder = nil

local started = false
local startedComplete = false
local onStartedComplete = Instance.new("BindableEvent")


local function DoesControllerExist(controllerName: string): boolean
	local controller: Controller? = controllers[controllerName]
	return controller ~= nil
end


local function GetServicesFolder()
	if not servicesFolder then
		servicesFolder = script.Parent:WaitForChild("Services")
	end
	return servicesFolder
end


local function GetMiddlewareForService(serviceName: string)
	local CrystalMiddleware = selectedOptions.Middleware or {}
	local serviceMiddleware = selectedOptions.PerServiceMiddleware[serviceName]
	return serviceMiddleware or CrystalMiddleware
end


local function BuildService(serviceName: string)
	local folder = GetServicesFolder()
	local middleware = GetMiddlewareForService(serviceName)
	local clientComm = ClientComm.new(folder, selectedOptions.ServicePromises, serviceName)
	local service = clientComm:BuildObject(middleware.Inbound, middleware.Outbound)
	services[serviceName] = service
	return service
end


--[=[
	Creates a new controller.

	:::caution
	Controllers must be created _before_ calling `Crystal.Start()`.
	:::
	```lua
	-- Create a controller
	local MyController = Crystal.CreateController {
		Name = "MyController",
	}

	function MyController:CrystalStart()
		print("MyController started")
	end

	function MyController:CrystalInit()
		print("MyController initialized")
	end
	```
]=]
function CrystalClient.CreateController(controllerDef: ControllerDef): Controller
	assert(type(controllerDef) == "table", "Controller must be a table; got " .. type(controllerDef))
	assert(type(controllerDef.Name) == "string", "Controller.Name must be a string; got " .. type(controllerDef.Name))
	assert(#controllerDef.Name > 0, "Controller.Name must be a non-empty string")
	assert(not DoesControllerExist(controllerDef.Name), "Controller \"" .. controllerDef.Name .. "\" already exists")
	local controller = controllerDef :: Controller
	controllers[controller.Name] = controller
	return controller
end


--[=[
	Requires all the modules that are children of the given parent with an optional affix. This is an easy
	way to quickly load all controllers that might be in a folder.
	```lua
	Crystal.AddControllers(somewhere.Controllers)
	```
]=]
function CrystalClient.AddControllers(parent: Instance, affix: string): {Controller}
	local addedControllers = {}
	for _,v in ipairs(parent:GetChildren()) do
		if not v:IsA("ModuleScript") then continue end
		if not v.Name:match(affix or "") then continue end
		table.insert(addedControllers, require(v))
	end
	return addedControllers
end


--[=[
	Requires all the modules that are descendants of the given parent with an optional affix.
]=]
function CrystalClient.AddControllersDeep(parent: Instance, affix: string): {Controller}
	local addedControllers = {}
	for _,v in ipairs(parent:GetDescendants()) do
		if not v:IsA("ModuleScript") then continue end
		if not v.Name:match(affix or "") then continue end
		table.insert(addedControllers, require(v))
	end
	return addedControllers
end


--[=[
	Returns a Service object which is a reflection of the remote objects
	within the Client table of the given service. Throws an error if the
	service is not found.

	If a service's Client table contains RemoteSignals and/or RemoteProperties,
	these values are reflected as
	[ClientRemoteSignals](https://sleitnick.github.io/RbxUtil/api/ClientRemoteSignal) and
	[ClientRemoteProperties](https://sleitnick.github.io/RbxUtil/api/ClientRemoteProperty).

	```lua
	-- Server-side service creation:
	local MyService = Crystal.CreateService {
		Name = "MyService",
		Client = {
			MySignal = Crystal.CreateSignal(),
			MyProperty = Crystal.CreateProperty("Hello"),
		},
	}
	function MyService:AddOne(player, number)
		return number + 1
	end

	-------------------------------------------------

	-- Client-side service reflection:
	local MyService = Crystal.GetService("MyService")

	-- Call a method:
	local num = MyService:AddOne(5) --> 6

	-- Fire a signal to the server:
	MyService.MySignal:Fire("Hello")

	-- Listen for signals from the server:
	MyService.MySignal:Connect(function(message)
		print(message)
	end)

	-- Observe the initial value and changes to properties:
	MyService.MyProperty:Observe(function(value)
		print(value)
	end)
	```

	:::caution
	Services are only exposed to the client if the service has remote-based
	content in the Client table. If not, the service will not be visible
	to the client. `CrystalClient.GetService` will only work on services that
	expose remote-based content on their Client tables.
	:::
]=]
function CrystalClient.GetService(serviceName: string): Service
	local service = services[serviceName]
	if service then
		return service
	end
	assert(started, "Cannot call GetService until Crystal has been started")
	assert(type(serviceName) == "string", "ServiceName must be a string; got " .. type(serviceName))
	return BuildService(serviceName)
end


--[=[
	Gets the controller by name. Throws an error if the controller
	is not found.
]=]
function CrystalClient.GetController(controllerName: string): Controller
	local controller = controllers[controllerName]
	if controller then
		return controller
	end
	assert(started, "Cannot call GetController until Crystal has been started")
	assert(type(controllerName) == "string", "ControllerName must be a string; got " .. type(controllerName))
	error("Could not find controller \"" .. controllerName .. "\". Check to verify a controller with this name exists.", 2)
end


--[=[
	@return Promise
	Starts Crystal. Should only be called once per client.
	```lua
	Crystal.Start():andThen(function()
		print("Crystal started!")
	end):catch(warn)
	```

	By default, service methods exposed to the client will return promises.
	To change this behavior, set the `ServicePromises` option to `false`:
	```lua
	Crystal.Start({ServicePromises = false}):andThen(function()
		print("Crystal started!")
	end):catch(warn)
	```
]=]
function CrystalClient.Start(options: CrystalOptions?)

	if started then
		return Promise.reject("Crystal already started")
	end

	started = true

	if options == nil then
		selectedOptions = defaultOptions
	else
		assert(typeof(options) == "table", "CrystalOptions should be a table or nil; got " .. typeof(options))
		selectedOptions = options
		for k,v in pairs(defaultOptions) do
			if selectedOptions[k] == nil then
				selectedOptions[k] = v
			end
		end
	end
	if type(selectedOptions.PerServiceMiddleware) ~= "table" then
		selectedOptions.PerServiceMiddleware = {}
	end

	return Promise.new(function(resolve)

		-- Init:
		local promisesStartControllers = {}

		for _,controller in pairs(controllers) do
			if type(controller.CrystalInit) == "function" then
				table.insert(promisesStartControllers, Promise.new(function(r)
					debug.setmemorycategory(controller.Name)
					controller:CrystalInit()
					r()
				end))
			end
		end

		resolve(Promise.all(promisesStartControllers))

	end):andThen(function()

		-- Start:
		for _,controller in pairs(controllers) do
			if type(controller.CrystalStart) == "function" then
				task.spawn(function()
					debug.setmemorycategory(controller.Name)
					controller:CrystalStart()
				end)
			end
		end

		startedComplete = true
		onStartedComplete:Fire()

		task.defer(function()
			onStartedComplete:Destroy()
		end)

	end)

end


--[=[
	@return Promise
	Returns a promise that is resolved once Crystal has started. This is useful
	for any code that needs to tie into Crystal controllers but is not the script
	that called `Start`.
	```lua
	Crystal.OnStart():andThen(function()
		local MyController = Crystal.GetController("MyController")
		MyController:DoSomething()
	end):catch(warn)
	```
]=]
function CrystalClient.OnStart()
	if startedComplete then
		return Promise.resolve()
	else
		return Promise.fromEvent(onStartedComplete.Event)
	end
end


return CrystalClient
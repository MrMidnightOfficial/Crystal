--[=[
	@interface Middleware
	.Inbound ServerMiddleware?
	.Outbound ServerMiddleware?
	@within CrystalServer
]=]
type Middleware = {
	Inbound: ServerMiddleware?,
	Outbound: ServerMiddleware?,
}

--[=[
	@type ServerMiddlewareFn (player: Player, args: {any}) -> (shouldContinue: boolean, ...: any)
	@within CrystalServer

	For more info, see [ServerComm](https://sleitnick.github.io/RbxUtil/api/ServerComm/) documentation.
]=]
type ServerMiddlewareFn = (player: Player, args: {any}) -> (boolean, ...any)

--[=[
	@type ServerMiddleware {ServerMiddlewareFn}
	@within CrystalServer
	An array of server middleware functions.
]=]
type ServerMiddleware = {ServerMiddlewareFn}

--[=[
	@interface ServiceDef
	.Name string
	.Client table?
	.Middleware Middleware?
	.[any] any
	@within CrystalServer
	Used to define a service when creating it in `CreateService`.

	The middleware tables provided will be used instead of the Crystal-level
	middleware (if any). This allows fine-tuning each service's middleware.
	These can also be left out or `nil` to not include middleware.
]=]
type ServiceDef = {
	Name: string,
	Client: {[any]: any}?,
	Middleware: Middleware?,
	[any]: any,
}

--[=[
	@interface Service
	.Name string
	.Client ServiceClient
	.CrystalComm Comm
	.[any] any
	@within CrystalServer
]=]
type Service = {
	Name: string,
	Client: ServiceClient,
	CrystalComm: any,
	[any]: any,
}

--[=[
	@interface ServiceClient
	.Server Service
	.[any] any
	@within CrystalServer
]=]
type ServiceClient = {
	Server: Service,
	[any]: any,
}

--[=[
	@interface CrystalOptions
	.Middleware Middleware?
	@within CrystalServer

	- Middleware will apply to all services _except_ ones that define
	their own middleware.
]=]
type CrystalOptions = {
	Middleware: Middleware?,
}

local defaultOptions: CrystalOptions = {
	Middleware = nil,
}

local selectedOptions = nil

--[=[
	@class CrystalServer
	@server
	Crystal server-side lets developers create services and expose methods and signals
	to the clients.

	```lua
	local Crystal = require(somewhere.Crystal)

	-- Load service modules within some folder:
	Crystal.AddServices(somewhere.Services)

	-- Start Crystal:
	Crystal.Start():andThen(function()
		print("Crystal started")
	end):catch(warn)
	```
]=]
local CrystalServer = {}

--[=[
	@prop Util Folder
	@within CrystalServer
	@readonly
	References the Util folder. Should only be accessed when using Crystal as
	a standalone module. If using Crystal from Wally, modules should just be
	pulled in via Wally instead of relying on Crystal's Util folder, as this
	folder only contains what is necessary for Crystal to run in Wally mode.
]=]
CrystalServer.Util = script.Parent.Parent

local SIGNAL_MARKER = newproxy(true)
getmetatable(SIGNAL_MARKER).__tostring = function()
	return "SIGNAL_MARKER"
end

local PROPERTY_MARKER = newproxy(true)
getmetatable(PROPERTY_MARKER).__tostring = function()
	return "PROPERTY_MARKER"
end

local CrystalRepServiceFolder = Instance.new("Folder")
CrystalRepServiceFolder.Name = "Services"

local Promise = require(CrystalServer.Util.Promise)
local Comm = require(CrystalServer.Util.Comm)
local ServerComm = Comm.ServerComm

local services: {[string]: Service} = {}
local started = false
local startedComplete = false
local onStartedComplete = Instance.new("BindableEvent")


local function DoesServiceExist(serviceName: string): boolean
	local service: Service? = services[serviceName]
	return service ~= nil
end


--[=[
	Constructs a new service.

	:::caution
	Services must be created _before_ calling `Crystal.Start()`.
	:::
	```lua
	-- Create a service
	local MyService = Crystal.CreateService {
		Name = "MyService",
		Client = {},
	}

	-- Expose a ToAllCaps remote function to the clients
	function MyService.Client:ToAllCaps(player, msg)
		return msg:upper()
	end

	-- Crystal will call CrystalStart after all services have been initialized
	function MyService:CrystalStart()
		print("MyService started")
	end

	-- Crystal will call CrystalInit when Crystal is first started
	function MyService:CrystalInit()
		print("MyService initialize")
	end
	```
]=]
function CrystalServer.CreateService(serviceDef: ServiceDef): Service
	assert(type(serviceDef) == "table", "Service must be a table; got " .. type(serviceDef))
	assert(type(serviceDef.Name) == "string", "Service.Name must be a string; got " .. type(serviceDef.Name))
	assert(#serviceDef.Name > 0, "Service.Name must be a non-empty string")
	assert(not DoesServiceExist(serviceDef.Name), "Service \"" .. serviceDef.Name .. "\" already exists")
	local service = serviceDef
	service.CrystalComm = ServerComm.new(CrystalRepServiceFolder, serviceDef.Name)
	if type(service.Client) ~= "table" then
		service.Client = {Server = service}
	else
		if service.Client.Server ~= service then
			service.Client.Server = service
		end
	end
	services[service.Name] = service
	return service
end

--[=[
	Constructs a new service. (PROMISE)

	:::caution
	Services must be created _before_ calling `Crystal.Start()`.
	:::
	```lua
	-- Create a service
	local MyService = Crystal.CreateServicePromise {
		Name = "MyService",
		Client = {},
	}

	-- Expose a ToAllCaps remote function to the clients
	function MyService.Client:ToAllCaps(player, msg)
		return msg:upper()
	end

	-- Crystal will call CrystalStart after all services have been initialized
	function MyService:CrystalStart()
		print("MyService started")
	end

	-- Crystal will call CrystalInit when Crystal is first started
	function MyService:CrystalInit()
		print("MyService initialize")
	end
	```
]=]
function CrystalServer.CreateServicePromise(serviceDef: ServiceDef): Service
 return Promise.new(function(resolve)
	assert(type(serviceDef) == "table", "Service must be a table; got " .. type(serviceDef))
	assert(type(serviceDef.Name) == "string", "Service.Name must be a string; got " .. type(serviceDef.Name))
	assert(#serviceDef.Name > 0, "Service.Name must be a non-empty string")
	assert(not DoesServiceExist(serviceDef.Name), "Service \"" .. serviceDef.Name .. "\" already exists")
	local service = serviceDef
	service.CrystalComm = ServerComm.new(CrystalRepServiceFolder, serviceDef.Name)
	if type(service.Client) ~= "table" then
		service.Client = {Server = service}
	else
		if service.Client.Server ~= service then
			service.Client.Server = service
		end
	end
	services[service.Name] = service
	resolve(service)
    end)
end





--[=[
	Requires all the modules that are children of the given parent with an optional affix. This is an easy
	way to quickly load all services that might be in a folder.
	```lua
	Crystal.AddServices(somewhere.Services)
	```
]=]
function CrystalServer.AddServices(parent: Instance, affix: string): {Service}
	local addedServices = {}
	for _,v in ipairs(parent:GetChildren()) do
		if not v:IsA("ModuleScript") then continue end
		if not v.Name:match(affix or "") then continue end
		table.insert(addedServices, require(v))
	end
	return addedServices
end


--[=[
	Requires all the modules that are descendants of the given parent with an optional affix.
]=]
function CrystalServer.AddServicesDeep(parent: Instance, affix: string): {Service}
	local addedServices = {}
	for _,v in ipairs(parent:GetDescendants()) do
		if not v:IsA("ModuleScript") then continue end
		if not v.Name:match(affix or "") then continue end
		table.insert(addedServices, require(v))
	end
	return addedServices
end


--[=[
	Gets the service by name. Throws an error if the service is not found.
]=]
function CrystalServer.GetService(serviceName: string): Service
	assert(started, "Cannot call GetService until Crystal has been started")
	assert(type(serviceName) == "string", "ServiceName must be a string; got " .. type(serviceName))
	return assert(services[serviceName], "Could not find service \"" .. serviceName .. "\"") :: Service
end


--[=[
	@return SIGNAL_MARKER
	Returns a marker that will transform the current key into
	a RemoteSignal once the service is created. Should only
	be called within the Client table of a service.

	See [RemoteSignal](https://sleitnick.github.io/RbxUtil/api/RemoteSignal)
	documentation for more info.
	```lua
	local MyService = Crystal.CreateService {
		Name = "MyService",
		Client = {
			-- Create the signal marker, which will turn into a
			-- RemoteSignal when Crystal.Start() is called:
			MySignal = Crystal.CreateSignal(),
		},
	}

	function MyService:CrystalInit()
		-- Connect to the signal:
		self.Client.MySignal:Connect(function(player, ...) end)
	end
	```
]=]
function CrystalServer.CreateSignal()
	return SIGNAL_MARKER
end


--[=[
	@return PROPERTY_MARKER
	Returns a marker that will transform the current key into
	a RemoteProperty once the service is created. Should only
	be called within the Client table of a service. An initial
	value can be passed along as well.

	RemoteProperties are great for replicating data to all of
	the clients. Different data can also be set per client.

	See [RemoteProperty](https://sleitnick.github.io/RbxUtil/api/RemoteProperty)
	documentation for more info.

	```lua
	local MyService = Crystal.CreateService {
		Name = "MyService",
		Client = {
			-- Create the property marker, which will turn into a
			-- RemoteProperty when Crystal.Start() is called:
			MyProperty = Crystal.CreateProperty("HelloWorld"),
		},
	}

	function MyService:CrystalInit()
		-- Change the value of the property:
		self.Client.MyProperty:Set("HelloWorldAgain")
	end
	```
]=]
function CrystalServer.CreateProperty(initialValue: any)
	return {PROPERTY_MARKER, initialValue}
end


--[=[
	@return Promise
	Starts Crystal. Should only be called once.

	Optionally, `CrystalOptions` can be passed in order to set
	Crystal's custom configurations.

	:::caution
	Be sure that all services have been created _before_
	calling `Start`. Services cannot be added later.
	:::

	```lua
	Crystal.Start():andThen(function()
		print("Crystal started!")
	end):catch(warn)
	```
	
	Example of Crystal started with options:
	```lua
	Crystal.Start({
		Middleware = {
			Inbound = {
				function(player, args)
					print("Player is giving following args to server:", args)
					return true
				end
			},
		},
	}):andThen(function()
		print("Crystal started!")
	end):catch(warn)
	```
]=]
function CrystalServer.Start(options: CrystalOptions?)

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

	return Promise.new(function(resolve)

		local CrystalMiddleware = selectedOptions.Middleware or {}

		-- Bind remotes:
		for _,service in pairs(services) do
			local middleware = service.Middleware or {}
			local inbound = middleware.Inbound or CrystalMiddleware.Inbound
			local outbound = middleware.Outbound or CrystalMiddleware.Outbound
			service.Middleware = nil
			for k,v in pairs(service.Client) do
				if type(v) == "function" then
					service.CrystalComm:WrapMethod(service.Client, k, inbound, outbound)
				elseif v == SIGNAL_MARKER then
					service.Client[k] = service.CrystalComm:CreateSignal(k, inbound, outbound)
				elseif type(v) == "table" and v[1] == PROPERTY_MARKER then
					service.Client[k] = service.CrystalComm:CreateProperty(k, v[2], inbound, outbound)
				end
			end
		end

		-- Init:
		local promisesInitServices = {}
		for _,service in pairs(services) do
			if type(service.CrystalInit) == "function" then
				table.insert(promisesInitServices, Promise.new(function(r)
					debug.setmemorycategory(service.Name)
					service:CrystalInit()
					r()
				end))
			end
		end

		resolve(Promise.all(promisesInitServices))

	end):andThen(function()

		-- Start:
		for _,service in pairs(services) do
			if type(service.CrystalStart) == "function" then
				task.spawn(function()
					debug.setmemorycategory(service.Name)
					service:CrystalStart()
				end)
			end
		end

		startedComplete = true
		onStartedComplete:Fire()

		task.defer(function()
			onStartedComplete:Destroy()
		end)

		-- Expose service remotes to everyone:
		CrystalRepServiceFolder.Parent = script.Parent

	end)

end


--[=[
	@return Promise
	Returns a promise that is resolved once Crystal has started. This is useful
	for any code that needs to tie into Crystal services but is not the script
	that called `Start`.
	```lua
	Crystal.OnStart():andThen(function()
		local MyService = Crystal.Services.MyService
		MyService:DoSomething()
	end):catch(warn)
	```
]=]
function CrystalServer.OnStart()
	if startedComplete then
		return Promise.resolve()
	else
		return Promise.fromEvent(onStartedComplete.Event)
	end
end


return CrystalServer

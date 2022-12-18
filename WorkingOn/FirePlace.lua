--!nonstrict
--// Initialization

local FirePlace = {}
FirePlace.__index = FirePlace

type FirePlaceTask = () -> () | Instance | RBXScriptConnection | FirePlace
type FirePlace = typeof(setmetatable({_Tasks = {}:: {FirePlaceTask}}, FirePlace))

--// Functions

function FirePlace.new(): FirePlace
	return setmetatable({_Tasks = {}}, FirePlace)
end

function FirePlace:GiveTask(Task: FirePlaceTask)
	table.insert(self._Tasks, Task)
end

function FirePlace:LinkToInstance(Object: Instance)
	self:GiveTask(Object)
	self:GiveTask(Object.Destroying:Connect(function()
		self:Burn()
	end))
end

function FirePlace:Burn()
	local Tasks = self._Tasks
	self._Tasks = {}
	
	for _, Task in next, Tasks do
		local TaskType = typeof(Task)
		local IsTable = (TaskType == "table")
		
		if TaskType == "RBXScriptConnection" or (IsTable and Task.Disconnect) then
			Task:Disconnect()
		elseif TaskType == "Instance" or (IsTable and Task.Destroy) then
			Task:Destroy()
		else
			Task()
		end
	end
	
	table.clear(Tasks)
end

FirePlace.Disconnect = FirePlace.Burn
FirePlace.Destroy = FirePlace.Burn

return table.freeze(FirePlace)

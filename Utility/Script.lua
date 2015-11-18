Script = {
	scene = nil,
	stage = 1,
	timer = 0,
	exists = true,
	active = true,
	value = nil
}

function Script:loadScript(ScriptFile, Value)
	s = {}
	setmetatable(s, self)
	self.__index = self
	
	s.finished = false
	s.stage = 1
	s.timer = 0
	s.value = Value

	s.exists = true
	s.active = true

	Script.load(s, ScriptFile)
	
	return s
end

function Script:load(File)
	self.scene = loadfile(File)
	--dofile("Scripts/cutscene_1.lua")
end

function Script:update()
	value = self.value
	timer = self.timer + General.elapsed
	stage = self.stage
	self.stage = self.scene()
	if self.stage == -1 then
		self.active = false
		GameState.scripts:delete(self)
	end
	
	--Get updated timer value
	self.timer = timer
end

function Script:draw()
end

--[[ Dispose of the object
]]
function Script:destroy()
	for k, v in ipairs(self) do
		self[k] = nil
	end
	self = nil
end

function Script:getType()
	return "Script"
end

function Script:getDebug()
	printStr = self:getType() .. "\n"
	--printStr = printStr .. "\tActive: " .. self.active .. "\n"
	printStr = printStr .. "\tStage: " .. self.stage .. "\n"
	printStr = printStr .. "\tTimer: " .. self.timer .. "\n"
	return printStr
end
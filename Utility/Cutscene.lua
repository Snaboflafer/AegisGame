Cutscene = {
	scene = nil,
	stage = 1,
	timer = 0,
	exists = true,
	active = true
}

function Cutscene:loadScene(Scene)
	s = {}
	setmetatable(s, self)
	self.__index = self
	
	s.finished = false
	s.stage = 1
	s.timer = 0
	
	s.exists = true
	s.active = true
	
	--s.scene = loadfile(Scene)
	Cutscene.load(s, Scene)
	
	return s
end

function Cutscene:load(Scene)
	self.scene = loadfile(Scene)
	--dofile("Scripts/cutscene_1.lua")
end

function Cutscene:update()
	timer = self.timer + General.elapsed
	stage = self.stage
	self.stage = self.scene()
	if self.stage == -1 then
		self.active = false
	end
	
	--Get updated timer value
	self.timer = timer
end

function Cutscene:draw()
end

--[[ Dispose of the object
]]
function Cutscene:destroy()
	for k, v in ipairs(self) do
		self[k] = nil
	end
	self = nil
end

function Cutscene:getType()
	return "Cutscene"
end
function Cutscene:getDebug()
	printStr = self:getType() .. "\n"
	--printStr = printStr .. "\tActive: " .. self.active .. "\n"
	printStr = printStr .. "\tStage: " .. self.stage .. "\n"
	printStr = printStr .. "\tTimer: " .. self.timer .. "\n"
	return printStr
end
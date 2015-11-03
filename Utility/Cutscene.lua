Cutscene = {
	scene = nil,
	stage = 1,
	finished = false
}

function Cutscene:loadScene(Scene)
	s = {}
	setmetatable(s, self)
	self.__index = self
	
	s.finished = false
	
	Cutscene.load(s, Scene)
	
	return s
end

function Cutscene:load(Scene)
	self.scene = loadfile(Scene)
	dofile("Scripts/cutscene_1.lua")
end

function Cutscene:update()
	self.scene()
end
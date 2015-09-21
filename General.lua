--General class for game data
General = {
	elapsed = 0,
	camera = {x=0, y=0},
	volume = 1,
	timeScale = 1,
	screenW = 0,
	screenH = 0,
	activeState = nil
}

function General:init()
	s = {}
	
	setmetatable(s, self)
	self.__index = self
	
	self.elapsed = 0
	self.camera = {}
	self.volume = 1
	self.timeScale = 1
	self.screenW = love.window.getWidth()
	self.screenH = love.window.getHeight()
	self.activeState = nil
	
	return s
end

function General:getFPS()
	return 1/General.elapsed
end

function General:newCamera(X, Y)
	if (self.camera ~= nil) then
		--self.camera:destroy()
	end
	
	self.camera = {}
	self.camera = {
		x = 0,
		y = 0
	}
end

function General:setState(NewState, CloseOld)
	if CloseOld == nil then
		CloseOld = true
	end
	if CloseOld then
		if self.activeState ~= nil then
			self.activeState:unload()
		end
	end
	
	self.activeState = NewState
	if not self.activeState.loaded then
		self.activeState:load()
	end
	self.activeState:start()
end

return General

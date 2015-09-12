--General class for game data
general = {
	elapsed = 0,
	camera = {
		x=0,
		y=0
	},
	volume = 1,
	timeScale = 1,
	screenW = 0,
	screenH = 0
}

local function init(self)
	self = self or {}
	
	self = setmetatable({}, { __index = general})
	
	self.elapsed = 0
	self.camera = {}
	self.volume = 1
	self.timeScale = 1
	self.screenW = love.window.getWidth()
	self.screenH = love.window.getHeight()
	
	return snbG
end

local function newCamera(self, X, Y)
	if (self.camera ~= nil) then
		--self.camera:destroy()
	end
	
	self.camera = {}
	self.camera = {
		x = 0,
		y = 0
	}
end

return {
	init = init,
	newCamera = newCamera
}
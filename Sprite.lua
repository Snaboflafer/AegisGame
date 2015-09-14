--Class for Sprites. Should extend Object

Sprite = {
	x = 0,
	y = 0,
	width = 0,
	height = 0,
	velocityX = 0,
	velocityY = 0,
	accelerationX = 0,
	accelerationY = 0,
	rotation = 0,
	originX = 0,
	originY = 0,
	offsetX = 0,
	offsetY = 0,
	scaleX = 1,
	scaleY = 1,
	rotation = 0,
	imageFile = "[NO IMAGE]",
	image = love.graphics.newImage("/images/img_blank.png"),
	lockToScreen = false
}

-- new function based on http://www.lua.org/pil/16.1.html
-- Sprite["new"] = function(self, X, Y, ImageFile)
-- Sprite.new = function(self, X, Y, ImageFile)
function Sprite:new(X,Y, ImageFile, Width, Height)
	-- make a temp object with either the provided object or a new one
	-- if none is provided
	s = {}
	-- makes object a prototype for Sprite
	-- setmetatable(s, { __index = object})
	setmetatable(s, self)
	-- basically Sprite.__index = Sprite
	self.__index = self
	s.x = X
	s.y = Y
	s.width = Width or 0
	s.height = Height or 0
	if (ImageFile ~= nil) then
		s.imageFile = ImageFile
		s.image = love.graphics.newImage(s.imageFile)
	end
	return s
end

function Sprite:sayHi()
	love.graphics.print("Hi", 100,100)
end

-- updates velocity and position of sprite
function Sprite:update()
	self.velocityX = self.velocityX + self.accelerationX
	self.velocityY = self.velocityY + self.accelerationY
	self.x = self.x + self.velocityX
	self.y = self.y + self.velocityY
	if (lockToScreen) then
		if self.y < 0 then
			self.y = 0
		elseif self.y + self.height > General.screenH then
			self.y = General.screenH - self.height
		elseif self.x < 0 then
			self.x = 0
		elseif self.x + self.width > General.screenW then
			self.x = General.screenW - self.width
		end
	end
end	

-- draws sprite
function Sprite:draw()
	love.graphics.draw(
		self.image,
		self.x,
		self.y,
		self.rotation,
		self.scaleX, self.scaleY,
		self.offsetX, self.offsetY
	)
end

function Sprite:lockToScreen(value)
	lockToScreen = value or true
end
	
function Sprite:getDebug()
	debugStr = ""
	debugStr = debugStr .. "\t Image = " .. self.imageFile .. "\n"
	debugStr = debugStr .. "\t x = " .. math.floor(self.x) .. "\n"
	debugStr = debugStr .. "\t y = " .. math.floor(self.y) .. "\n"
	debugStr = debugStr .. "\t width = " .. self.width .. ", height = " .. self.height .. "\n"
	debugStr = debugStr .. "\t velocity = " .. math.floor(self.velocityX) .. ", " .. math.floor(self.velocityY) .. "\n"
	debugStr = debugStr .. "\t acceleration = " .. self.accelerationX .. ", " .. self.accelerationY .. "\n"
	return debugStr
end

return Sprite

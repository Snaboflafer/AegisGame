--Class for Sprites. Should extend Object

Sprite = {
	x = 0,
	y = 0,
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
}

--[[  
-- new function in prototype.lua fashion
function newSprite(X,Y, ImageFile) {
	local s = {
		x = X,
		y = Y,
	}
	if (ImageFile ~= nil) then
		imageFile = ImageFile
		image = love.graphics.newImage(imageFile)
	setmetatable(s, Sprite)
	return s
}
--]]

-- new function based on http://www.lua.org/pil/16.1.html
-- Sprite["new"] = function(self, X, Y, ImageFile)
-- Sprite.new = function(self, X, Y, ImageFile)
function Sprite:new(X,Y, ImageFile)
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
	
function Sprite:getDebug()
	debugStr = ""
	debugStr = debugStr .. "\t Image = " .. self.imageFile .. "\n"
	debugStr = debugStr .. "\t x = " .. math.floor(self.x) .. "\n"
	debugStr = debugStr .. "\t y = " .. math.floor(self.y) .. "\n"
	debugStr = debugStr .. "\t velocity = " .. math.floor(self.velocityX) .. ", " .. math.floor(self.velocityY) .. "\n"
	debugStr = debugStr .. "\t acceleration = " .. self.accelerationX .. ", " .. self.accelerationY .. "\n"
	return debugStr
end

return Sprite

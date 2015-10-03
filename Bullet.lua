--Class for sprites. Should extend Object
Bullet = {
	friendly = true,
	pointValue = 0
}

function Bullet:new(X,Y,ImageFile,friendly)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	self.friendly = friendly
	return s
end

function Bullet:update()
	self.lockToScreen = false
	Sprite.update(self)
end

function Bullet:reset(X, Y, VX, VY)
	self.x = X
	self.y = Y
	self.velocityY = VY
	self.velocityX = VX
end

function Bullet:getPointValue()
	return self.pointValue
end

function Bullet:getType()
	return "Bullet"
end

return Bullet	
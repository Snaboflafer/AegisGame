-- the "ground" of our game is just a big rectangle sprite
WrappingSprite = {
}

function WrappingSprite:new(X,Y,ImageFile, width, height)
	local s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.width = width
	s.height = height
	s.velocityX = 1
	return s
end

function WrappingSprite:update()
	if self.x < 0 then
		self.x = General.screenW
	end
	Sprite.update(self)
end

function WrappingSprite:getType()
	return "wrappingSprite"
end

return WrappingSprite

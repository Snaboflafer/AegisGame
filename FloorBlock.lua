-- the "ground" of our game is just a big rectangle sprite
FloorBlock = {
}

function FloorBlock:new(X,Y,ImageFile, width, height)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	self.width = width
	self.height = height
	return s
end

function FloorBlock:update()
	Sprite.update(self)
end

function FloorBlock:getType()
	return "FloorBlock"
end

return FloorBlock

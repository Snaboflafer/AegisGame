Effect = {
}

function Effect:new(Width, Height,ImageFile, Width, Height)
	s = Sprite:new(0,0,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	self:loadSpriteSheet(ImageFile, Width, Height)

	return s
end

function

return Effect

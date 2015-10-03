Effect = {
}

function Effect:new(Name, ImageFile, Width, Height)
	s = Sprite:new(0,0, ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	self:loadSpriteSheet(ImageFile, Width, Height)
	self:addAnimation(Name, {1,2}, 0.1, false)
	return s
end

function Effect:play(Name, X, Y)
	self:setPosition(X, Y)
	self:playAnimation(Name)
end

return Effect

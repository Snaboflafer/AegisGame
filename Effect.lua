Effect = {
}

function Effect:new(ImageFile)
	s = Sprite:new(0,0, ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	return s
end

function Effect:initialize(Name, ImageFile, Width, Height)
	self:loadSpriteSheet(ImageFile, Width, Height)
	self:addAnimation(Name, {1,2,3,4,5,6,7,8}, 0.1, false)
end

function Effect:play(Name, X, Y)
	self:setPosition(X, Y)
	self:playAnimation(Name, true)

end

return Effect

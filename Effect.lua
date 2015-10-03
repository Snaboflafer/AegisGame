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
	self:addAnimation(Name, {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}, 0.01, false)
end

function Effect:play(Name, X, Y)
	self:setPosition(X - self.width / 2, Y - self.height / 2)
	self:playAnimation(Name, true)

end

return Effect

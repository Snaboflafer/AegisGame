--Class for sprites. Should extend Object
Enemy = Sprite:new{}

function Enemy:update()
	math.randomseed(time*self.y)
	self.accelerationX = (math.random() - 0.5)*1000
	self.accelerationY = (math.random() - 0.5)*1000
	Sprite.update(self)
	if touchingU or touchingD then self.velocityY = -self.velocityY end
	if touchingR or touchingL then self.velocityX = -self.velocityX end
end

return Enemy	
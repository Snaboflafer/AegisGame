--Class for sprites. Should extend Object
Enemy = Sprite:new()

function Enemy:update()
	math.randomseed(os.time())
	self.accelerationX = math.random() - 0.5
	self.accelerationY = math.random() - 0.5
	self.velocityX = (self.velocityX + self.accelerationX)
	self.velocityY = (self.velocityY + self.accelerationY)
	if self.velocityX > 10 then self.velocityX = 10 end
	if self.velocityY > 10 then self.velocityY = 10 end
	if self.velocityX < -10 then self.velocityX = -10 end
	if self.velocityY < -10 then self.velocityY = -10 end
	self.x = self.x + self.velocityX
	self.y = self.y + self.velocityY
	
end

return Enemy
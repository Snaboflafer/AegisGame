--Class for sprites. Should extend Object
Enemy = Sprite:new()

function Enemy:update()
	--math.randomseed(os.time())
	math.randomseed(os.time() * self.x * self.y)
	--Above line is more random, but jittery.
	
	
	--[[self.accelerationX = math.random() - 0.5
	self.accelerationY = math.random() - 0.5
	self.velocityX = (self.velocityX + self.accelerationX)
	self.velocityY = (self.velocityY + self.accelerationY)
	if self.velocityX > 10 then self.velocityX = 10 end
	if self.velocityY > 10 then self.velocityY = 10 end
	if self.velocityX < -10 then self.velocityX = -10 end
	if self.velocityY < -10 then self.velocityY = -10 end --]]
	self.velocityX = (math.random() - 0.5)*5
	self.velocityY = (math.random() - 0.5)*5
	self.x = self.x + self.velocityX
	self.y = self.y + self.velocityY
	if (lockToScreen) then
		if self.y < 0 then
			self.y = 0
		elseif self.y + self.height > General.screenH then
			self.y = General.screenH - self.height
		end
		if self.x < 0 then
			self.x = 0
		elseif self.x + self.width > General.screenW then
			self.x = General.screenW - self.width
		end
	end
	
	
end

return Enemy
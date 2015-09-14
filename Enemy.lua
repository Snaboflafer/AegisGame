--Class for sprites. Should extend Object
Enemy = Sprite:new()

function Enemy:update()
	self.x = self.x + self.velocityX
	self.y = self.y + self.velocityY
		enemyID = enemyID or 1;
		math.randomseed(os.time()*enemyID)
		self.velocityX = (math.random() - 0.5)*10
		self.velocityY = (math.random() - 0.5)*10
	if (lockToScreen) then
		if self.y < 0 then
			self.y = 0
			self.velocityY = 0
		elseif self.y + self.height > General.screenH then
			self.y = General.screenH - self.height
			self.velocityY = 0
		end
		if self.x < 0 then
			self.x = 0
			self.velocityX = 0
		elseif self.x + self.width > General.screenW then
			self.x = General.screenW - self.width
			self.velocityX = 0
		end
	else 
	end
	
	
end

return Enemy	
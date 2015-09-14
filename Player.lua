Player = Sprite:new(X,Y, ImageFile)

Player.magnitude = 100
Player.momentArm = math.sqrt(Player.magnitude^2/2)

-- as of now you must use this method to change the magnitude
-- otherwise, the momentArm will not be recalculated
function Player:changeMagnitude(m)
	self.magnitude = m
	self.momentArm = math.sqrt(self.magnitude^2/2)
end
function Player:update()
	if love.keyboard.isDown('w') and love.keyboard.isDown('d') then
        	self.velocityX = self.momentArm
		self.velocityY = -self.momentArm
	elseif love.keyboard.isDown('d') and love.keyboard.isDown('s') then
        	self.velocityX = self.momentArm
		self.velocityY = self.momentArm
	elseif love.keyboard.isDown('s') and love.keyboard.isDown('a') then
        	self.velocityX = -self.momentArm
		self.velocityY = self.momentArm
	elseif love.keyboard.isDown('a') and love.keyboard.isDown('w') then
        	self.velocityX = -self.momentArm
		self.velocityY = -self.momentArm
	elseif love.keyboard.isDown('w') then
        	self.velocityX = 0
		self.velocityY = -self.magnitude
	elseif love.keyboard.isDown('s') then
        	self.velocityX = 0
		self.velocityY = self.magnitude
	elseif love.keyboard.isDown('a') then
        	self.velocityX = -self.magnitude
		self.velocityY = 0
	elseif love.keyboard.isDown('d') then
        	self.velocityX = self.magnitude
		self.velocityY = 0
    	end
	Sprite.update(self)
end


return Player

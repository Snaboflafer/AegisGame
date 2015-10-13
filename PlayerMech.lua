PlayerMech = {
	enableControls = true
}

function PlayerMech:new(X,Y,ImageFile)
	s = Player:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Player)
	self.__index = self
	
	s.dragX = 20
	s.accelerationY = 2000
	s.maxVelocityX = 400
	
	return s
end

function PlayerMech:setAnimations()
	self:addAnimation("idle", {1}, .5, true)
	self:playAnimation("idle")
end

function PlayerMech:update()
	if self.enableControls then
		--self.weapons[self.activeWeapon]:setPosition(self.x+66, self.y+12)
		if love.keyboard.isDown("d") then
			self.accelerationX = 500
		elseif love.keyboard.isDown("a") then
			self.accelerationX = -500
		else
			self.accelerationX = 0
		end
		
		if love.keyboard.isDown("k") and self.touching == Sprite.DOWN then
			self.velocityY = -800
		end
		--Keep up with screen scrolling
		--self.velocityX = self.velocityX + GameState.cameraFocus.velocityX
	end
	self:playAnimation("idle")
	
	
	Player.update(self)
end

function PlayerMech:getType()
	return "PlayerMech"
end

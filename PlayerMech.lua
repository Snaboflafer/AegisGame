PlayerMech = {
	enableControls = true,
	activeMode = "mech",
	JUMPPOWER = 600,
	GRAVITY = 1500,
	DRAG = 20,
}

function PlayerMech:new(X,Y,ImageFile)
	s = Player:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Player)
	self.__index = self
	
	s.dragX = self.DRAG
	s.accelerationY = self.GRAVITY
	
	s.change = love.audio.newSource(LevelManager:getSound("mech_to_ship"))

	return s
end

function PlayerMech:setAnimations()
	self:addAnimation("idle", {1}, .5, false)
	self:addAnimation("walk_f", {2,3,4,7,8,9,10,1}, .15, true)
	self:addAnimation("walk_b", {10,9,8,7,4,3,2,1}, .25, true)
	self:addAnimation("attack_f", {11,12,13,14,15}, .1, true)
	self:playAnimation("idle")
end

function PlayerMech:update()
	if self.enableControls then
		--self.weapons[self.activeWeapon]:setPosition(self.x+66, self.y+12)
		if love.keyboard.isDown("d") then
			self.accelerationX = 350
			self.maxVelocityX = 200
		elseif love.keyboard.isDown("a") then
			self.accelerationX = -200
			self.maxVelocityX = 120
		else
			self.accelerationX = 0
		end
		
		if self.touching == Sprite.DOWN then
			--On ground
			self.dragX = self.DRAG
			if love.keyboard.isDown("k") then
				self.velocityY = -self.JUMPPOWER
			end
		else
			--In air
			self.dragX = self.DRAG / 10
		end
		
	end
	
	if self.velocityX > 0 then
		self:playAnimation("walk_f")
	elseif self.velocityX < 0 then
		self:playAnimation("walk_b")
	else
		self:playAnimation("idle")
	end
	
	Player.update(self)
end

function PlayerMech:enterMode(X, Y, VX, VY, HP)
	self.change:rewind()
	self.change:play()
	self.x = X
	self.y = Y
	self.velocityX = VX
	self.velocityY = VY
	self.health = HP
	self:setExists(true)
end

function PlayerMech:exitMode()
	self.weapons[self.activeWeapon]:stop()
	self:setExists(false)
	return self.x, self.y, self.velocityX, self.velocityY, self.health
end

function PlayerMech:attackStart()
	self.weapons[self.activeWeapon]:restart()
end
function PlayerMech:attackStop()
	self.weapons[self.activeWeapon]:stop()
	self:playAnimation("idle")
end

function PlayerMech:fireGun()
	self:playAnimation("attack_f", true, true)
end

function PlayerMech:collideGround()
	if self.velocityY > 100 then
		General.activeState.camera:screenShake(.01,.05)
	end
end

function PlayerMech:getType()
	return "PlayerMech"
end

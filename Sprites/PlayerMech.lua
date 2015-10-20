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
	s.hitGround = love.audio.newSource(LevelManager:getSound("hit_ground"))
	return s
end

function PlayerMech:setAnimations()
	self:addAnimation("idle", {1}, .5, false)
	self:addAnimation("walk_f", {2,3,4,7,8,9,10,1}, .15, true)
	self:addAnimation("walk_b", {10,9,8,7,4,3,2,1}, .25, true)
	self:addAnimation("attack_f", {11,12,13,14,15}, .1, true)
	self:playAnimation("idle")
end

local hittingGround = false
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
			if (hittingGround == false) then
				self.hitGround:rewind()
				self.hitGround:play()
				hittingGround = true
			end
			self.dragX = self.DRAG
			if love.keyboard.isDown("k") then
				self.velocityY = -self.JUMPPOWER
			end
		else
			--In air
			if (hittingGround == true) then
				hittingGround = false
			end
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

--[[ Enter mech mode
	X	X position
	Y	Y position
	VX	X velocity
	VY	Y velocity
	HP	Health
	SP	Shields
]]
function PlayerMech:enterMode(X, Y, VX, VY, HP, SP)
	self.change:rewind()
	self.change:play()
	self.x = X - self.width/2
	self.y = Y - self.height/2
	self.velocityX = VX
	self.velocityY = VY
	self.health = HP
	self.shield = SP
	self.exists = true
	
	if GameState.shieldOverlay ~= nil and GameState.shieldBar ~= nil then
		GameState.shieldOverlay:setColor({255,255,255})
		GameState.shieldBar:setAlpha(255)
	end
end

--[[ Exit mech mode. Returns required arguments for enterMode()
]]
function PlayerMech:exitMode()
	self.weapons[self.activeWeapon]:stop()
	self.exists = false
	return self.x+self.width/2, self.y+self.height/2, self.velocityX, self.velocityY, self.health, self.shield
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

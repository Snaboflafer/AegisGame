PlayerMech = {
	enableControls = true,
	activeMode = "mech",
	JUMPPOWER = 600,
	GRAVITY = 1400,
	DRAG = 200,
	fuel = 3,
	maxFuel = 3,
	jetThrust = -100
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
	s.sfxStep = love.audio.newSource(LevelManager:getSound("player_step"))
	s.sfxJump = love.audio.newSource(LevelManager:getSound("player_jump"))

	return s
end

function PlayerMech:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
	self:addAnimation("walk_f", {2,3,4,7,8,9,10,1}, .15, true)
	self:addAnimation("walk_b", {10,9,8,7,4,3,2,1}, .2, true)
	self:addAnimation("attack_f", {11,12,13,14,15}, .1, true)
	self:addAnimation("jump_f_u", {16,17,18}, .2, false)
	self:addAnimation("jump_f_d", {18}, 0, false)
	self:playAnimation("idle")
end

--[[ Assign Jet and Smoke emitters for the thruster
]]
function PlayerMech:assignThruster(Jet, Smoke)
	self.thrust_jet = Jet
	self.thrust_smoke = Smoke
end

function PlayerMech:update()

	local pressedUp 
	local pressedDown
	local pressedLeft
	local pressedRight
	local pressedJump
	if self.enableControls then
		pressedUp = love.keyboard.isDown("w")
		pressedDown = love.keyboard.isDown("s")
		pressedLeft = love.keyboard.isDown("a")
		pressedRight = love.keyboard.isDown("d")
		pressedJump = love.keyboard.isDown("k")
	else
		pressedUp = false
		pressedDown = false
		pressedLeft = false
		pressedRight = false
		pressedJump = false
	end
	
	--self.weapons[self.activeWeapon]:setPosition(self.x+66, self.y+12)
	if pressedRight then
		self.accelerationX = 800
		self.maxVelocityX = 200
	elseif pressedLeft then
		self.accelerationX = -550
		self.maxVelocityX = 120
	else
		self.accelerationX = 0
	end
	
	local animStr = "idle"
	if self.touching == Sprite.DOWN then
		--On ground
		
		if (self.curAnimFrame == 1 and self.lastAnimFrame ~= 1) then
			GameState.groundParticle:play(self.x + self.width*.65, self.y+self.height-6)
			self.sfxStep:play()
			--General:getCamera():screenShake(.003, .05)
		elseif (self.curAnimFrame == 5 and self.lastAnimFrame ~= 5) then
			GameState.groundParticle:play(self.x + self.width*.25, self.y+self.height-6)
			self.sfxStep:play()
			--General:getCamera():screenShake(.003, .05)
		end
		
		self.accelerationY = self.GRAVITY
		
		
		self.dragX = self.DRAG
		if pressedJump then
			self.velocityY = -self.JUMPPOWER
			self.sfxJump:play()
		end
		
		if self.fuel < self.maxFuel then
			self.fuel = self.fuel + General.elapsed * 10
			if self.fuel > self.maxFuel then
				self.fuel = self.maxFuel
			end
		end
	else
		--In air
		self.dragX = self.DRAG / 10

		--	if self.velocityY < 0 then
		--		animStr = "jump_f_u"
		--	else
		--		animStr = "jump_f_d"
		--	end
		
		local accY = self.accelerationY
		if pressedJump and self.velocityY>-50 and self.fuel > 0 then
			--Enable boost
			self.thrust_smoke:restart()
			
			local maxThrust = self.jetThrust
			if accY	> maxThrust then
				accY = accY - General.elapsed*12*(accY - maxThrust)
			end
			self.accelerationY = accY
			self.fuel = self.fuel - General.elapsed
			self.maxVelocityY = 45
			--animStr = "jump_f_d"
		else
			self.thrust_smoke:stop()
			local gravity = self.GRAVITY
			if accY < gravity then
				accY = accY + General.elapsed * 2 * (gravity - accY)
				if accY > gravity then
					accY = gravity
				end
				self.accelerationY = accY
			end
			
			self.maxVelocityY = 1000
		end
	end
	

	if pressedUp then
		self.weapons[self.activeWeapon]:setAngle(20, 1)
		self.weapons[self.activeWeapon]:lockParent(self, false, 87, -24)
	elseif pressedDown then
		self.weapons[self.activeWeapon]:setAngle(-20, 1)
		self.weapons[self.activeWeapon]:lockParent(self, false, 87, 56)
	else
		self.weapons[self.activeWeapon]:setAngle(0,1)
		self.weapons[self.activeWeapon]:lockParent(self, false, 100, 14)
	end
	
	if self.velocityX > 0 then
		animStr = "walk_f"
	elseif self.velocityX < 0 then
		animStr = "walk_b"
	end

	self:playAnimation(animStr)
	
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
	self.thrust_smoke:stop()
	self.exists = false
	return self.x+self.width/2, self.y+self.height/2, self.velocityX, self.velocityY, self.health, self.shield
end

function PlayerMech:attackStart()
	self.weapons[self.activeWeapon]:restart()
end
function PlayerMech:attackStop()
	self.weapons[self.activeWeapon]:stop()
	if self.weaponCasings[self.activeWeapon] ~= nil then
		self.weaponCasings[self.activeWeapon]:stop()
	end
	if self.weaponFlashes[self.activeWeapon] ~= nil then
		self.weaponFlashes[self.activeWeapon]:stop()
	end
	
	self:playAnimation("idle")
end

function PlayerMech:fireGun()
	self:playAnimation("attack_f", true, true)
	if self.weaponCasings[self.activeWeapon] ~= nil then
		self.weaponCasings[self.activeWeapon]:restart()
	end
	if self.weaponFlashes[self.activeWeapon] ~= nil then
		self.weaponFlashes[self.activeWeapon]:restart()
	end
end

function PlayerMech:collideGround()
	if self.velocityY > 100 then
		General.activeState.camera:screenShake(.01,.05)
		self.hitGround:rewind()
		self.hitGround:play()
		GameState.groundParticle:play(self.x + self.width*.25, self.y+self.height-6)
	end
end

function PlayerMech:getType()
	return "PlayerMech"
end

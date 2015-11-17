PlayerMech = {
	activeMode = "mech",
	JUMPPOWER = 600,
	GRAVITY = 1400,
	DRAG = 200,
	DEFAULTOFFX = 22,
	DEFAULTOFFY = 16,
	DEFAULTW = 48, 
	DEFAULTH = 112,
	ANGLEU = 20,
	ANGLEF = 0,
	ANGLED = -15,
	fuel = 3,
	maxFuel = 3,
	gunAngle = 0,
	jetThrust = -100,
	isDucking = false,
	isAttacking = false,
	isHovering = false,
	onFloor = false
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

	s.sfxJetStart = love.audio.newSource(LevelManager:getSound("jet_start"))
	s.sfxJetStart:setLooping(false)
	s.sfxJetStart:setVolume(.4)
	s.sfxJetLoop = love.audio.newSource(LevelManager:getSound("jet_loop"))
	s.sfxJetLoop:setLooping(true)
	s.sfxJetLoop:setVolume(.2)

	return s
end

function PlayerMech:setAnimations()
	self:addAnimation("idle_u", {1}, 0, false)
	self:addAnimation("idle_f", {9}, 0, false)
	self:addAnimation("idle_d", {41}, 0, false)
	self:addAnimation("walk_f_u", {2,3,4,5,6,7,8,1}, .12, true)
	self:addAnimation("walk_b_u", {8,7,6,5,4,3,2,1}, .14, true)
	self:addAnimation("walk_f_f", {10,11,12,13,14,15,16,9}, .12, true)
	self:addAnimation("walk_b_f", {16,15,14,13,12,11,10,9}, .14, true)
	self:addAnimation("walk_f_d", {18,19,20,21,22,23,24,17}, .12, true)
	self:addAnimation("walk_b_d", {24,23,22,21,20,19,18,17}, .14, true)
	self:addAnimation("fire_u",   {26,27,28,29,30,31,32,25}, .05, true)
	self:addAnimation("fire_f",   {34,35,36,37,38,39,40,33}, .05, true)
	self:addAnimation("fire_d",   {42,43,44,45,46,47,48,41}, .05, true)
	self:addAnimation("jump_u_u", {49}, 0, false)
	self:addAnimation("jump_d_u", {50}, 0, false)
	self:addAnimation("jump_u_f", {51}, 0, false)
	self:addAnimation("jump_d_f", {52}, 0, false)
	self:addAnimation("jump_u_d", {53}, 0, false)
	self:addAnimation("jump_d_d", {54}, 0, false)
	
	self:playAnimation("idle_f")
end

function PlayerMech:setCollisionBox(X, Y, W, H)
	Sprite.setCollisionBox(self,X,Y,self.DEFAULTW,self.DEFAULTH)
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
	local pressedAttack
	
	if Player.enableControls then
		pressedUp = love.keyboard.isDown("w")
		pressedDown = love.keyboard.isDown("s")
		pressedLeft = love.keyboard.isDown("a")
		pressedRight = love.keyboard.isDown("d")
		pressedJump = love.keyboard.isDown("k")
		pressedAttack = love.keyboard.isDown(" ")
	else
		pressedUp = false
		pressedDown = false
		pressedLeft = false
		pressedRight = false
		pressedJump = false
		pressedAttack = false
	end
	
	--self.weapons[self.activeWeapon]:setPosition(self.x+66, self.y+12)
	local animStr = "idle"
	local animRestart = false
	local animForced = false
	local lastAnim = string.sub(self.curAnim.name, 1, 4)
	if self.touching == Sprite.DOWN then
		self.onFloor = true
	else
		self.onFloor = false
	end
	
	if self.onFloor then
		--On ground

		self.dragX = self.DRAG
		self.accelerationY = self.GRAVITY

		--Handle horizontal movement
		if pressedRight and not self.isDucking then
			self.accelerationX = 800
			self.maxVelocityX = 200
			animStr = "walk_f"
		elseif pressedLeft and not self.isDucking then
			self.accelerationX = -550
			self.maxVelocityX = 120
			animStr = "walk_b"
		else
			self.accelerationX = 0
			animStr = "idle"
		end
		
		--Footstep effects
		if lastAnim == "walk" and self.curAnimFrame == 1 and self.lastAnimFrame ~= 1 then
			GameState.groundParticle:play(self.x + self.width*.65, self.y+self.height-6)
			self.sfxStep:play()
		elseif lastAnim == "walk" and self.curAnimFrame == 5 and self.lastAnimFrame ~= 5 then
			GameState.groundParticle:play(self.x + self.width*.25, self.y+self.height-6)
			self.sfxStep:play()
		end
		
		--Handle ducking
		if pressedDown and not (pressedRight or pressedLeft) then
			self:duck(true)
		else
			self:duck(false)
		end

		if self.isAttacking and self.velocityX == 0 then
			animStr = "fire"
		end

		
		if pressedJump then
			self:jump()
			self:duck(false)
		end
		
		self:jetOff()
		if self.fuel < self.maxFuel then
			self.fuel = self.fuel + General.elapsed * 10
			if self.fuel > self.maxFuel then
				self.fuel = self.maxFuel
			end
		end
	else
		--In air
		self.dragX = self.DRAG / 10
		
		--Handle horizontal movement
		if pressedRight then
			self.accelerationX = 400
			self.maxVelocityX = 200
		elseif pressedLeft then
			self.accelerationX = -350
			self.maxVelocityX = 120
		else
			self.accelerationX = 0
		end

		if pressedJump then
			self:jetOn()
		end
		
		if self.isHovering then
			local accY = self.accelerationY
	
			local maxThrust = self.jetThrust
			if accY	> maxThrust then
				accY = accY - General.elapsed*12*(accY - maxThrust)
			end
			self.accelerationY = accY
			self.fuel = self.fuel - General.elapsed
			--animStr = "jump_f_d"
		else
			local accY = self.accelerationY
			local gravity = self.GRAVITY
			if accY < gravity then
				accY = accY + General.elapsed * 2 * (gravity - accY)
				if accY > gravity then
					accY = gravity
				end
				self.accelerationY = accY
			end
		end
		
		if self.velocityY < -10 then
			animStr = "jump_u"
		else
			animStr = "jump_d"
		end
	end
	
	--Handle aiming
	if pressedUp then
		self.gunAngle = PlayerMech.ANGLEU
		self.weapons[self.activeWeapon]:lockParent(self, false, 87, -20)
			self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 87, -20)
		animStr = animStr .. "_u"
	elseif pressedDown and not self.isDucking then
		self.gunAngle = PlayerMech.ANGLED
		self.weapons[self.activeWeapon]:lockParent(self, false, 97, 46)
		self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 100, 36)
		animStr = animStr .. "_d"
	else
		self.gunAngle = PlayerMech.ANGLEF
		if self.isDucking then
			self.weapons[self.activeWeapon]:lockParent(self, false, 100, 28)
			self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 90, 28)
			animStr = animStr .. "_d"
		else
			self.weapons[self.activeWeapon]:lockParent(self, false, 100, 14)
			self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 90, 14)
			animStr = animStr .. "_f"
		end
	end
	self.weapons[self.activeWeapon]:setAngle(self.gunAngle, 1)
	

	self:playAnimation(animStr, animRestart, animForced)
	
	Player.update(self)
end

function PlayerMech:jump()
	self.velocityY = -self.JUMPPOWER
	self.sfxJump:play()
	
	if self.isDucking then
		self.height = self.DEFAULTH
		self.y = self.y - 16
		self.isDucking = false
	end
end

function PlayerMech:duck(Enable)
	if Enable then
		if not self.isDucking then
			self.height = self.DEFAULTH - 20
			self.offsetY = self.DEFAULTOFFY + 20
			self.y = self.y + 20
			self.isDucking = true
		end
	else
		if self.isDucking then
			self.height = self.DEFAULTH
			self.offsetY = self.DEFAULTOFFY
			self.y = self.y - 20
			self.isDucking = false
		end
	end
end

function PlayerMech:jetOn()
	if self.fuel <= 0 or self.velocityY < -50 then
		self:jetOff()
		return false
	end
	--Enable boost
	if not self.isHovering then
		self.sfxJetStart:rewind()
		self.sfxJetStart:play()
	end
	self.sfxJetLoop:play()

	
	self.thrust_smoke:restart()
	self.maxVelocityY = 45

	self.isHovering = true
	
	return true
end

function PlayerMech:jetOff()
	self.maxVelocityY = 1000
	self.isHovering = false
	self.thrust_smoke:stop()
	--self.sfxJetStart:stop()
	self.sfxJetLoop:stop()
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
	self:jetOff()
	self.exists = false
	return self.x+self.width/2, self.y+self.height/2, self.velocityX, self.velocityY, self.health, self.shield
end

function PlayerMech:attackStart()
	self.weapons[self.activeWeapon]:restart()
	self.isAttacking = true
	Timer:new(self.weapons[self.activeWeapon].emitDelay, self, PlayerMech.attackStop)
end
function PlayerMech:attackStop()
	if love.keyboard.isDown(" ") then
		Timer:new(self.weapons[self.activeWeapon].emitDelay, self, PlayerMech.attackStop)
		return
	end

	self.weapons[self.activeWeapon]:stop()
	self.isAttacking = false
	if self.weaponCasings[self.activeWeapon] ~= nil then
		self.weaponCasings[self.activeWeapon]:stop()
	end
	if self.weaponFlashes[self.activeWeapon] ~= nil then
		self.weaponFlashes[self.activeWeapon]:stop()
	end
	
	--self:playAnimation("idle")
end

function PlayerMech:fireGun()
	if self.onFloor and self.velocityX == 0 then
		local animStr = "fire"
		if self.gunAngle == PlayerMech.ANGLEU then
			self.weapons[self.activeWeapon]:setAngle(20, 1)
			self.weapons[self.activeWeapon]:lockParent(self, false, 87, -24)
			animStr = animStr .. "_u"
		elseif self.gunAngle == PlayerMech.ANGLED and not self.isDucking then
			self.weapons[self.activeWeapon]:setAngle(-15, 1)
			self.weapons[self.activeWeapon]:lockParent(self, false, 87, 46)
			animStr = animStr .. "_d"
		else
			self.weapons[self.activeWeapon]:setAngle(0,1)
			self.weapons[self.activeWeapon]:lockParent(self, false, 100, 14)
			if self.isDucking then
				animStr = animStr .. "_d"
			else
				animStr = animStr .. "_f"
			end
		end
		self:playAnimation(animStr, true)
	end
	if not self.onFloor then
		self.x = self.x - 5
		self.velocityX = self.velocityX - 25
	end
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

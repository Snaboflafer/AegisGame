PlayerMech = {
	activeMode = "mech",
	attackCooldownTimer = nil,
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
	fuel = 4,
	maxFuel = 4,
	gunAngle = 0,
	jetThrust = -200,
	jetMaxFactor = .4,
	isDucking = false,
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
	self:addAnimation("fire_u",   {26,27,28,29,30,31,32,25}, .06, false)
	self:addAnimation("fire_f",   {34,35,36,37,38,39,40,33}, .06, false)
	self:addAnimation("fire_d",   {42,43,44,45,46,47,48,41}, .06, false)
	self:addAnimation("jump_u_u", {49}, 0, false)
	self:addAnimation("jump_d_u", {50}, 0, false)
	self:addAnimation("jump_u_f", {51}, 0, false)
	self:addAnimation("jump_d_f", {52}, 0, false)
	self:addAnimation("jump_u_d", {53}, 0, false)
	self:addAnimation("jump_d_d", {54}, 0, false)
	
	self:playAnimation("idle_f")
end

function PlayerMech:doConfig()
	Player.doConfig(self)
	
	self.attackCooldownTimer = Timer:new(.1, self, PlayerMech.attackStop, false)
	self.attackCooldownTimer:stop()
	
	image, height, width = LevelManager:getPlayerMech()
	self:loadSpriteSheet(image, height, width)
	self:setAnimations()
	self:setCollisionBox(22,16,PlayerMech.DEFAULTW, PlayerMech.DEFAULTH)
	self:lockToScreen(Sprite.ALL)
	--self.showDebug = true
	
	local playerCasings = Emitter:new(0,0)
	for i=1,14 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("bullet_casing"), 12, 12)
		curParticle:setCollisionBox(2,2,8,8)
		curParticle:addAnimation("default", {1,2,3,4}, .03, true)
		curParticle:playAnimation("default")
		playerCasings:addParticle(curParticle)
		GameState.worldParticles:add(curParticle)
	end
	playerCasings:setSpeed(400)
	playerCasings:setAngle(115, 10)
	playerCasings:setGravity(1000)
	playerCasings:setDrag(50)
	playerCasings:lockParent(self, false, 30, 20)
	playerCasings:start(true, 1.5, .3, 1)
	playerCasings:stop()
	GameState.emitters:add(playerCasings)

	local playerFlash = Emitter:new(0,0)
	for i=1,2 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getImage("muzzleFlash"), 32, 32)
		curParticle:addAnimation("default", {1, 2}, .01, false)
		curParticle:playAnimation("default")
		curParticle:setCollisionBox(4,4,24,24)
		playerFlash:addParticle(curParticle)
	end
	playerFlash:setSpeed(0)
	playerFlash:lockParent(self, false, 95, 24)
	playerFlash:start(false, .02, 1, 1)
	playerFlash:stop()
	GameState.emitters:add(playerFlash)

	--Weapon 1: Standard	DPS:	3.9
	local playerGun = Emitter:new(0,0)
	for i=1, 7 do
		local curParticle = Projectile:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("bullet-orange"), 20, 20)
		curParticle:setCollisionBox(4,4,14,14)
		curParticle:addAnimation("default", {1}, 0, false)
		curParticle:addAnimation("kill", {2,3,4,5}, .02, false)
		curParticle:playAnimation("default")
		curParticle.attackPower = 1.1
		playerGun:addParticle(curParticle)
		GameState.playerBullets:add(curParticle)
		GameState.worldParticles:add(curParticle)
	end
	playerGun:setSpeed(600,625)
	playerGun:setAngle(0,1)
	playerGun:lockParent(self, false, 112, 26)
	playerGun:setSound(LevelManager:getSound("cannon"))
	playerGun:setCallback(self, PlayerMech.fireWeapon)
	playerGun:start(false, 2, .28, -1)
	playerGun:stop()
	GameState.emitters:add(playerGun)
	self:addWeapon(playerGun, 1, playerCasings, playerFlash, 0)
	
	--Weapon 2: Napalm		DPS:	6.7
	local playerGun = Emitter:new(0,0)
	for i=1, 10 do
		local curParticle = Projectile:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("bullet-orange"), 20, 20)
		curParticle:setCollisionBox(-4,-4,30,30)
		curParticle:addAnimation("default", {1}, 0, false)
		curParticle:addAnimation("kill", {2,3,4,5}, .02, false)
		curParticle:playAnimation("default")
		curParticle:setPersistance(true)
		curParticle.attackPower = .5
		curParticle.friction = .5
		curParticle.visible = false
		
		local fireTrail = Emitter:new()
		for i=1, 20 do
			--Create the trail sprites
			local curFlame = Sprite:new(0,0)
			curFlame:loadSpriteSheet(LevelManager:getParticle("fireball"), 32, 32)
			curFlame:addAnimation("default", {1,2,3,3,4,5,6,7,8,9,10}, .02, false)
			curFlame:playAnimation("default")
			fireTrail:addParticle(curFlame)
		end
		--Set fire trail parameters
		fireTrail:setAngle(135)
		fireTrail:setSpeed(20)
		fireTrail:setGravity(-400)
		fireTrail:setSize(16,16)
		fireTrail:lockParent(curParticle, true)
		fireTrail:start(false, .25, .01, -1)
		fireTrail:stop()
		GameState.emitters:add(fireTrail)
		GameState.worldParticles:add(fireTrail)

		playerGun:addParticle(curParticle)
		GameState.playerBullets:add(curParticle)
		GameState.worldParticles:add(curParticle)
	end
	playerGun:setSpeed(800)
	playerGun:setAngle(0,5)
	playerGun:setGravity(-200)
	playerGun:lockParent(self, false, 112, 26)
	playerGun:setSound(LevelManager:getSound("fire_1"))
	playerGun:setCallback(self, PlayerMech.fireWeapon)
	playerGun:start(false, .4, .06, -1)
	playerGun:stop()
	GameState.emitters:add(playerGun)
	self:addWeapon(playerGun, 2, nil, playerFlash, .1)

	--Weapon 3: Railgun		DPS:	2.7 (x2 => 5.4 on penetration)
	local playerGun = Emitter:new(0,0)
	for i=1, 4 do
		local curRail = Railbeam:new(0,0)
		curRail:doConfig()
		playerGun:addParticle(curRail)
	end
	playerGun:setSpeed(1500)
	playerGun:setAngle(0,1)
	playerGun:setRadial(true)
	playerGun:lockParent(self, false, 112, 26)
	playerGun:setSound(LevelManager:getSound("railgun"))
	playerGun:setCallback(self, PlayerMech.fireWeapon)
	playerGun:start(false, 2, .7, -1)
	playerGun:stop()
	GameState.emitters:add(playerGun)
	self:addWeapon(playerGun, 3, playerCasings, playerFlash, .5)

	
	--Create mech thruster
	local mechThrust_Jet = Emitter:new()
	for i=1, 10 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("fireball"), 32, 32)
		curParticle:addAnimation("default", {1,2,3,4,5,6,7,7,8,8,9,9,9,10}, .08, false)
		curParticle:playAnimation("default")
		mechThrust_Jet:addParticle(curParticle)
	end
	mechThrust_Jet:setSpeed(500,800)
	mechThrust_Jet:setAngle(245, 20)
	mechThrust_Jet:setGravity(-1000)
	mechThrust_Jet:setDrag(10)
	mechThrust_Jet:lockParent(self, false, -10, 34)
	mechThrust_Jet:setSize(12, 12)
	mechThrust_Jet:start(false, .2, .01, -1)
	mechThrust_Jet:stop()
	GameState.emitters:add(mechThrust_Jet)
	
	local mechThrust_Smoke = Emitter:new()
	for i=1, 10 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("smoke"), 32,32)
		curParticle:addAnimation("default", {1,1,1,2,3,4,3,2,1}, .015, false)
		curParticle:playAnimation("default")
		curParticle.bounceFactor = 1
		mechThrust_Smoke:addParticle(curParticle)
		GameState.worldParticles:add(curParticle)
		
		local curJet = Sprite:new(0,0)
		curJet:loadSpriteSheet(LevelManager:getParticle("fireball"), 32, 32)
		curJet:addAnimation("default", {1,2,3,5,9,9,10}, .017, false)
		curJet:playAnimation("default")
		curJet.bounceFactor = 1
		mechThrust_Smoke:addParticle(curJet)
	end
	mechThrust_Smoke:setSpeed(500,800)
	mechThrust_Smoke:setAngle(245, 10)
	mechThrust_Smoke:setGravity(-2000)
	mechThrust_Smoke:setDrag(200, 0)
	mechThrust_Smoke:lockParent(self, false, -12, 40)
	mechThrust_Smoke:setSize(16, 16)
	mechThrust_Smoke:start(false, .2, .01, -1)
	mechThrust_Smoke:stop()
	GameState.emitters:add(mechThrust_Smoke)

	self:assignThruster(mechThrust_Jet, mechThrust_Smoke)
end

function PlayerMech:addDefaultWeapon(slot)
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
		local lastAnim = string.sub(self.curAnim.name, 1, 6)
		if lastAnim == "walk_f" then
			if (self.curAnimFrame == 8 and self.lastAnimFrame == 7) or 
				(self.curAnimFrame == 4 and self.lastAnimFrame == 3) then
				GameState.groundParticle:play(self.x + self.width, self.y+self.height-6)
				self.sfxStep:rewind()
				self.sfxStep:play()
			end
		elseif lastAnim == "walk_b" then
			if (self.curAnimFrame == 8 and self.lastAnimFrame == 7) or 
				(self.curAnimFrame == 4 and self.lastAnimFrame == 3) then
				GameState.groundParticle:play(self.x, self.y+self.height-6)
				self.sfxStep:rewind()
				self.sfxStep:play()
			end
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
			self.accelerationX = 300
			self.maxVelocityX = 200
		elseif pressedLeft then
			self.accelerationX = -250
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
				accY = accY - General.elapsed*14*(accY - maxThrust)
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
		self:attachWeapon(92, -10)
		self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 92, -10)
		animStr = animStr .. "_u"
	elseif pressedDown and not self.isDucking then
		self.gunAngle = PlayerMech.ANGLED
		self:attachWeapon(102, 56)
		self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 105, 46)
		animStr = animStr .. "_d"
	else
		self.gunAngle = PlayerMech.ANGLEF
		if self.isDucking then
			self:attachWeapon(105, 38)
			self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 95, 38)
			animStr = animStr .. "_d"
		else
			self:attachWeapon(105, 24)
			self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 95, 24)
			animStr = animStr .. "_f"
		end
	end
	self:setWeaponAngle(self.gunAngle, 1)
	

	self:playAnimation(animStr, animRestart, animForced)
	
	Player.update(self)
end

function PlayerMech:jump()
	self.velocityY = -self.JUMPPOWER
	self.sfxJump:play()
	
	self:duck(false)
end

function PlayerMech:duck(Enable)
	if Enable and not self.isDucking then
		self.height = self.DEFAULTH - 20
		self.offsetY = self.DEFAULTOFFY + 20
		self.y = self.y + 20
		self.isDucking = true
	elseif not Enable and self.isDucking then
		self.height = self.DEFAULTH
		self.offsetY = self.DEFAULTOFFY
		self.y = self.y - 20
		self.isDucking = false
	end
end

function PlayerMech:jetOn()
	if self.fuel <= 0 or self.velocityY < self.jetThrust*self.jetMaxFactor then
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
	self.maxVelocityY = -self.jetThrust*self.jetMaxFactor - 5

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
	self:stopWeapon()
	self.thrust_smoke:stop()
	self:jetOff()
	self.exists = false
	return self.x+self.width/2, self.y+self.height/2, self.velocityX, self.velocityY, self.health, self.shield
end

function PlayerMech:attackStart()
	self:restartWeapon()
	self.isAttacking = true
	self.attackCooldownTimer:restart(self.weapons[self.activeWeapon].members[1].emitDelay)
end
function PlayerMech:attackStop()
	if love.keyboard.isDown(" ") then
		self.attackCooldownTimer:restart(self.weapons[self.activeWeapon].members[1].emitDelay)
		return
	end

	self:stopWeapon()
	self.isAttacking = false
	if self.weaponCasings[self.activeWeapon] ~= nil then
		self.weaponCasings[self.activeWeapon]:stop()
	end
	if self.weaponFlashes[self.activeWeapon] ~= nil then
		self.weaponFlashes[self.activeWeapon]:stop()
	end
	
	--self:playAnimation("idle")
end

function PlayerMech:fireWeapon()
	if self.onFloor and self.velocityX == 0 then
		local animStr = "fire"
		if self.gunAngle == PlayerMech.ANGLEU then
			self:setWeaponAngle(20, 1)
			self:attachWeapon(87, -24)
			animStr = animStr .. "_u"
		elseif self.gunAngle == PlayerMech.ANGLED and not self.isDucking then
			self:setWeaponAngle(-15, 1)
			self:attachWeapon(87, 46)
			animStr = animStr .. "_d"
		else
			self:setWeaponAngle(0, 1)
			self:attachWeapon(100, 14)
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
		self.velocityX = self.velocityX - (10*self.weapons[self.activeWeapon].members[1].emitDelay)^3
	end
	if self.weaponCasings[self.activeWeapon] ~= nil then
		self.weaponCasings[self.activeWeapon]:restart()
	end
	if self.weaponFlashes[self.activeWeapon] ~= nil then
		self.weaponFlashes[self.activeWeapon]:restart()
	end
	Player.fireWeapon(self)
end

function PlayerMech:collideGround()
	if self.velocityY > 100 then
		General.activeState.camera:screenShake(.01,.05)
		self.hitGround:rewind()
		self.hitGround:play()
		GameState.groundParticle:play(self.x + self.width*.3, self.y+self.height-10)
	end
end

function PlayerMech:getType()
	return "PlayerMech"
end

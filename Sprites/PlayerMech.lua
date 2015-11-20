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

function PlayerMech:doConfig()
	Player.doConfig(self)
	
	image, height, width = LevelManager:getPlayerMech()
	self:loadSpriteSheet(image, height, width)
	self:setAnimations()
	self:setCollisionBox(22,16,PlayerMech.DEFAULTW, PlayerMech.DEFAULTH)
	self:lockToScreen(Sprite.ALL)
	--self.showDebug = true
	
	--Attach gun to mech
	playerGun = Emitter:new(0,0)
	for i=1, 7 do
		local curParticle = Sprite:new(0,0, LevelManager:getParticle("bullet-orange"))
		curParticle.attackPower = 1.1
		playerGun:addParticle(curParticle)
		GameState.playerBullets:add(curParticle)
	end
	playerGun:setSpeed(600,625)
	playerGun:setAngle(0,1)
	playerGun:lockParent(self, false, 107, 16)
	playerGun:setSound(LevelManager:getSound("cannon"))
	playerGun:setCallback(self, PlayerMech.fireWeapon)
	playerGun:start(false, 2, .28, -1)
	playerGun:stop()
	GameState.emitters:add(playerGun)
	
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
	playerCasings:start(false, 1, .3, 1)
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
	playerFlash:lockParent(self, false, 90, 14)
	playerFlash:start(false, .02, 1, 1)
	playerFlash:stop()
	GameState.emitters:add(playerFlash)

	self:addWeapon(playerGun, 1, playerCasings, playerFlash)

	
	--Create mech thruster
	local mechThrust_Jet = Emitter:new()
	--Empty
	
	local mechThrust_Smoke = Emitter:new()
	for i=1, 15 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("smoke"), 32,32)
		curParticle:addAnimation("default", {1,1,1,2,3,4,3,2,1}, .01, false)
		curParticle:playAnimation("default")
		mechThrust_Smoke:addParticle(curParticle)
	end
	mechThrust_Smoke:setSpeed(500,800)
	mechThrust_Smoke:setAngle(245, 20)
	mechThrust_Smoke:setGravity(-4000)
	mechThrust_Smoke:setDrag(10)
	mechThrust_Smoke:lockParent(self, false, -20, 24)
	mechThrust_Smoke:setSize(12, 12)
	mechThrust_Smoke:start(false, .15, .01, -1)
	mechThrust_Smoke:stop()
	GameState.emitters:add(mechThrust_Smoke)

	self:assignThruster(mechThrust_Jet, mechThrust_Smoke)
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
		self:attachWeapon(87, -20)
		self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 87, -20)
		animStr = animStr .. "_u"
	elseif pressedDown and not self.isDucking then
		self.gunAngle = PlayerMech.ANGLED
		self:attachWeapon(97, 46)
		self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 100, 36)
		animStr = animStr .. "_d"
	else
		self.gunAngle = PlayerMech.ANGLEF
		if self.isDucking then
			self:attachWeapon(100, 28)
			self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 90, 28)
			animStr = animStr .. "_d"
		else
			self:attachWeapon(100, 14)
			self.weaponFlashes[self.activeWeapon]:lockParent(self, false, 90, 14)
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
	self:stopWeapon()
	self.thrust_smoke:stop()
	self:jetOff()
	self.exists = false
	return self.x+self.width/2, self.y+self.height/2, self.velocityX, self.velocityY, self.health, self.shield
end

function PlayerMech:attackStart()
	self:restartWeapon()
	self.isAttacking = true
	Timer:new(self.weapons[self.activeWeapon].emitDelay, self, PlayerMech.attackStop)
end
function PlayerMech:attackStop()
	if love.keyboard.isDown(" ") then
		Timer:new(self.weapons[self.activeWeapon].members[1].emitDelay, self, PlayerMech.attackStop)
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
		GameState.groundParticle:play(self.x + self.width*.3, self.y+self.height-10)
	end
end

function PlayerMech:getType()
	return "PlayerMech"
end

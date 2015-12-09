--Class for sprites. Should extend Object
Boss2 = {
	JUMPPOWER = 800,
	GRAVITY = 1400,
	WALKSPEED = 500,
	weapons = {}
}

function Boss2:new(X,Y,ImageFile)
	s = Enemy:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self
	
	s.NUMROUTES = 6
	s.route = 1
	s.health = 200
	s.maxHealth = 200
	s.score = 10000
	
	s.onFloor = true
	
	s.accelerationY = self.GRAVITY
	s.maxVelocityX = self.WALKSPEED*.2
	s.dragX = self.WALKSPEED*2
	
	s.weapons = {}

	s.hitGround = love.audio.newSource(LevelManager:getSound("hit_ground"))
	
	return s
end

function Boss2:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
	self:addAnimation("walk_l", {2,3,4,5,6,7,8,1}, .2, true)
	self:addAnimation("walk_r", {8,7,6,5,4,3,2,1}, .2, true)
	self:addAnimation("jump", {10,11,12,13,14,15,16,9}, .1, false)
	self:addAnimation("attack_eye_charge", {17,18,19,20}, .15, false)
	self:addAnimation("attack_eye_fire", {21,22,23}, .1, false)
	self:addAnimation("attack_eye_recover", {24,17}, .2, false)
	self:addAnimation("attack_kick", {26,27,28,29,30,31,32,25}, .1, false)
	self:addAnimation("attack_arm_aim", {33,34,35,36,37,38,39}, .15, false)
	self:addAnimation("attack_arm_fire", {40,41}, .2, false)
	self:addAnimation("attack_arm_recover", {42,43,44}, .15, false)
	self:playAnimation("idle")
end

function Boss2:respawn(SpawnX, SpawnY)
	SoundManager:playBgm("sounds/music/Zenon.ogg")
	if SpawnY == nil then
		Enemy.respawn(self, SpawnX, General.screenH/2)
	else
		Enemy.respawn(self, SpawnX, SpawnY)
	end
	GameState.bossHpBar.visible = true
	GameState.bossHpMask.visible = true
end

function Boss2:addWeapon(GunGroup, slot)
	self.weapons[slot] = GunGroup
end

function Boss2:doConfig()
	Enemy.doConfig(self)
	self:setCollisionBox(124,28,136,240)
	self.massless = false

	local gunRPG = Emitter:new(0,0)
	local ROCKETLIFESPAN = 5
	for j=1, 6 do
		--Create rockets
		local curRocket = HomingRocket:new(0,0)
		curRocket:doConfig()
		curRocket:lockTarget(GameState.playerShip)
		--local curRocket = Sprite:new(0,0, LevelManager:getParticle("bullet-red"))
		curRocket.attackPower = 1
		curRocket.dropRate = .3
		curRocket.lifeSpan = ROCKETLIFESPAN
		gunRPG:addParticle(curRocket)
		curRocket.killOffScreen = false
		GameState.enemyBullets:add(curRocket)
		GameState.destructables:add(curRocket)
		GameState.worldParticles:add(curRocket)
	end
	gunRPG:setSound(LevelManager:getSound("fire_2"))
	gunRPG:setSpeed(0, 10)
	gunRPG:setAngle(135, 20)
	gunRPG:setRadial(true)
	gunRPG:lockParent(self, false, -10,76)
	gunRPG:start(true, ROCKETLIFESPAN, 1, 1)
	gunRPG:stop()
	GameState.emitters:add(gunRPG)
	self:addWeapon(gunRPG, 1)
	
	--Weapon 2: Flamethrower
	local gunFlame = Emitter:new(0,0)
	for i=1, 20 do
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
		for i=1, 15 do
			--Create the trail sprites
			local curFlame = Sprite:new(0,0)
			curFlame:loadSpriteSheet(LevelManager:getParticle("fireball"), 32, 32)
			curFlame:addAnimation("default", {1,2,3,3,4,5,6,7,8,9,10}, .02, false)
			curFlame:playAnimation("default")
			fireTrail:addParticle(curFlame)
		end
		--Set fire trail parameters
		fireTrail:setAngle(45)
		fireTrail:setSpeed(20)
		fireTrail:setGravity(-400)
		fireTrail:setSize(16,16)
		fireTrail:lockParent(curParticle, true)
		fireTrail:start(false, .25, .01, -1)
		fireTrail:stop()
		GameState.emitters:add(fireTrail)

		gunFlame:addParticle(curParticle)
		GameState.enemyBullets:add(curParticle)
		GameState.worldParticles:add(curParticle)
	end
	gunFlame:setSpeed(200)
	gunFlame:setAngle(180,5)
	--gunFlame:lockTarget(GameState.playerMech)
	gunFlame:lockParent(self, false, -10, 76)
	gunFlame:setSound(LevelManager:getSound("jet_start"))
	--gunFlame:setCallback(self, PlayerMech.fireWeapon)
	gunFlame:start(false, 1.6, .1, -1)
	gunFlame:stop()
	GameState.emitters:add(gunFlame)
	self:addWeapon(gunFlame, 2)

	--Weapon 3: Railgun
	local gunLaser = Emitter:new(0,0)
	
	local curRail = Railbeam:new(0,0)
	curRail:doConfig()
	curRail.attackPower = 1
	GameState.enemyBullets:add(curRail)
	gunLaser:addParticle(curRail)
	
	gunLaser:setSpeed(1500)
	gunLaser:setAngle(180,1)
	gunLaser:setRadial(true)
	gunLaser:lockParent(self, false, 8, 40)
	gunLaser:setSound(LevelManager:getSound("railgun"))
	--gunLaser:setCallback(self, PlayerMech.fireWeapon)
	gunLaser:start(true, 2)
	gunLaser:stop()
	GameState.emitters:add(gunLaser)
	self:addWeapon(gunLaser, 3)
	
	self.laserCharge = Emitter:new()
	for i=1, 10 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("thruster"), 16, 8)
		curParticle:addAnimation("default", {1,2,3,4}, .1, true)
		curParticle:playAnimation("default")
		curParticle.originX = curParticle.width/2
		curParticle.originY = curParticle.height/2
		self.laserCharge:addParticle(curParticle)
	end
	self.laserCharge:setSpeed(-100, -350)
	self.laserCharge:setOffset(32)
	--self.laserCharge:setSize(32,32)
	self.laserCharge:setRadial(true)
	self.laserCharge:start(false, .1, .02, -1)
	self.laserCharge:stop()
	self.laserCharge:lockParent(self, false, 36, 32)
	GameState.emitters:add(self.laserCharge)
	
	--Weapon 4: Foot. Yes, this is a gun.
	local gunFoot = Emitter:new(0,0)
	local kickHitbox = Sprite:new(0,0)
	kickHitbox:createGraphic(130,64,{0,0,0},0)
	kickHitbox.attackPower = 1
	kickHitbox.immovable = true
	kickHitbox.bounceFactor = 100
	gunFoot:addParticle(kickHitbox)
	GameState.enemyBullets:add(kickHitbox)
	gunFoot:setSound(LevelManager:getSound("hit_ground"))
	gunFoot:setSpeed(400)
	gunFoot:setAngle(180,0)
	gunFoot:lockParent(self, false, 60, 170)
	gunFoot:start(true, .3)
	GameState.emitters:add(gunFoot)
	self:addWeapon(gunFoot, 4)
		
	self:nextRoute()
end

function Boss2:kill()
	Enemy.kill(self)
	self.weapons[1]:stop()
	self.weapons[2]:stop()
	GameState.bossHpBar.visible = false
	GameState.bossHpMask.visible = false
end

function Boss2:update()
	self:updateHealth()

	if self.route == 1 then
		--Idle
		if self.aiStage == 1 then
			self:playAnimation("idle")
			Timer:new(.3+math.random()*.3, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Idle
		elseif self.aiStage == 3 then
			self:nextRoute()
		end
	elseif self.route == 2 then
		--Move forwards
		if self.aiStage == 1 then
			if (math.random() < .3) or (GameState.player.y < self.y and math.random()<.8) then
				self:jump()
			end
			self.accelerationX = -self.WALKSPEED
			Timer:new(1+math.random(), self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Travelling
			if self.touching == Sprite.DOWN then
				self:playAnimation("walk_l", false, true)
			else
				self:playAnimation("jump")
			end
		elseif self.aiStage == 3 then
			self.accelerationX = 0
			self.route = 1
			self.aiStage = 1
		end
	elseif self.route == 3 then
		--Move backwards
		if self.aiStage == 1 then
			if (math.random() < .3) or (GameState.player.y < self.y and math.random()<.8)then
				self:jump()
			end
			self.accelerationX = self.WALKSPEED
			Timer:new(1+math.random(), self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Travelling
			if self.touching == Sprite.DOWN then
				self:playAnimation("walk_r")
			else
				self:playAnimation("jump")
			end
		elseif self.aiStage == 3 then
			self.accelerationX = 0
			self:idleRoute()
		end
	elseif self.route == 4 then
		--Attack (eye laser)
		if self.aiStage == 1 then
			self:flash({0,127,127}, .2, false)
			self:playAnimation("attack_eye_charge")
			Timer:new(1, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Charge (aiming)
			if self.animFinished then
				local player = GameState.player
				self.weapons[3]:setAngle(math.atan2((self.y+40) - (player.y + player.height/2),
									(player.x + player.width/2) - (self.x+8)) * 180/math.pi, 0)
				love.audio.newSource(LevelManager:getSound("charge")):play()
				self.laserCharge:restart()
				self:updateStage()
			end
		elseif self.aiStage == 3 then
			--Charge (finish)
		elseif self.aiStage == 4 then
			self.laserCharge:stop()
			self:playAnimation("attack_eye_fire")
			self:updateStage()
		elseif self.aiStage == 5 then
			if self.animFinished then
				self.weapons[3]:restart()
				Timer:new(.2, self, Boss2.updateStage)
				self:updateStage()
			end
		elseif self.aiStage == 6 then
			--End attack
		elseif self.aiStage == 7 then
			self:playAnimation("attack_eye_recover")
			Timer:new(.2, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 8 then
			--Recovering
		elseif self.aiStage == 9 then
			self:idleRoute()
		end
	elseif self.route == 5 then
		--Attack (missile)
		if self.aiStage == 1 then
			self:flash({127,0,128}, .2, false)
			self:playAnimation("attack_arm_aim")
			Timer:new(1.5, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Aiming
		elseif self.aiStage == 3 then
			self.weapons[1]:setAngle(180,5)
			for i=1, self.weapons[1].length do
				self.weapons[1].members[i]:lockTarget(GameState.player)
			end
			self.weapons[1]:restart()
			General.activeState.camera:screenShake(.005, .05)
			self:playAnimation("attack_arm_fire", true)
			Timer:new(1, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 4 then
			--Firing
			--self.weapons[2]:setAngle(170+math.sin(2*self.lifetime)*30, 5)
		elseif self.aiStage == 5 then
			self.weapons[2]:stop()
			if math.random()<.6 then
				self.aiStage = 3
			else
				self:playAnimation("attack_arm_recover")
				Timer:new(.7, self, Boss2.updateStage)
				self:updateStage()
			end
		elseif self.aiStage == 6 then
			--Recovering
		elseif self.aiStage == 7 then
			self:idleRoute()
		end
	elseif self.route == 6 then
		--Attack (flamethrower)
		if self.aiStage == 1 then
			self:flash({255,128,0}, .2, false)
			self:playAnimation("attack_arm_aim")
			Timer:new(1.5, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Aiming
		elseif self.aiStage == 3 then
			self.weapons[2]:setAngle(180,5)
			self.weapons[2]:restart()
			self:playAnimation("attack_arm_fire")
			General.activeState.camera:screenShake(.004, 4)
			Timer:new(4, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 4 then
			--Firing
			self.weapons[2]:setAngle(170+math.sin(2*self.lifetime)*30, 5)
		elseif self.aiStage == 5 then
			self.weapons[2]:stop()
			self:playAnimation("attack_arm_recover")
			Timer:new(.7, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 6 then
			--Recovering
		elseif self.aiStage == 7 then
			self:idleRoute()
		end
	elseif self.route == 7 then
		--Attack (kick)
		if self.aiStage == 1 then
			self:flash({150,150,150}, .2, false)
			Timer:new(.5, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Wait
		elseif self.aiStage == 3 then
			self:playAnimation("attack_kick")
			Timer:new(.3, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 4 then
			--Leg up
		elseif self.aiStage == 5 then
			self.weapons[4]:restart()
			Timer:new(.7, self, Boss2.updateStage)
			self:updateStage()
		elseif self.aiStage == 6 then
			--Kicking
		elseif self.aiStage == 7 then
			self:idleRoute()
		end
	elseif self.route == 8 then
		--Death
		self:kill()
	end
	
	Sprite.update(self)
end

function Boss2:jump()
	self.velocityY = -self.JUMPPOWER
	self.onFloor = false
	--self.sfxJump:play()
end

function Boss2:updateHealth()
	--Width is relative to size of health bar (value is defined in GameState, hardcoded here)
	local hpWidth = (self.health/self.maxHealth) * 105
	if hpWidth < 0 then
		hpWidth = 0
	end
	GameState.bossHpBar.scaleX = self.health/self.maxHealth
	if self.health <= 1 then
		GameState.bossHpBar:flash({128,0,0}, 1, true)
	end
end

function Boss2:idleRoute()
	for i=1, table.getn(self.weapons) do
		self.weapons[i]:stop()
	end
	self.route = 1
	self.aiStage = 1
end
function Boss2:nextRoute()
	for i=1, table.getn(self.weapons) do
		self.weapons[i]:stop()
	end
	if GameState.player.x > self.x or self:getScreenX() < General.screenW*.4 then
		--Move right if getting too close to left edge, or player gets past
		self.route = 3
	elseif self:getScreenX() > General.screenW*.8 then
		--Move left if getting too far offscreen
		self.route = 2
	elseif self.x-GameState.player.x < 150 and GameState.player.y - self.y > 100 and math.random()<.8 then
		--Kick if player gets close
		self.route = 7
	elseif self.x-GameState.player.x > 400 then
		--Don't use flamethrower if player is far away
		if math.random()<.8 then
			self.route = math.random(2, self.NUMROUTES-1)
		else
			self.route = math.random(4, self.NUMROUTES-1)
		end
	else
		self.route = 1
		if math.random()<.7 then
			self.route = math.random(2, self.NUMROUTES)
		else
			self.route = math.random(4, self.NUMROUTES)
		end
	end
	self.aiStage = 1
end

function Boss2:collide(Object)
	if self.touching == Sprite.DOWN and not self.onFloor then
		self.onFloor = true
		General.activeState.camera:screenShake(.02,.2)
		self.hitGround:rewind()
		self.hitGround:play()
		GameState.groundParticle:play(self.x + self.width*.3, self.y+self.height-10)
	end
end

function Boss2:getType()
	return "Boss2"
end

return Boss2	
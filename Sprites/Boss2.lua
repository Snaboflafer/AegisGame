--Class for sprites. Should extend Object
Boss2 = {
	JUMPPOWER = 600,
	GRAVITY = 1400,
	weapons = {}
}

function Boss2:new(X,Y,ImageFile)
	s = Enemy:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self
	
	s.NUMROUTES = 0
	s.route = 0
	s.health = 200
	s.maxHealth = 200
	s.score = 10000
	
	s.accelerationY = self.GRAVITY
	
	s.weapons = {}
	
	return s
end

function Boss2:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
	self:addAnimation("walk_l", {2,3,4,5,6,7,8,1}, .2, true)
	self:addAnimation("walk_r", {8,7,6,5,4,3,2,1}, .2, true)
	self:addAnimation("jump_u", {10,11,12,13}, .2, false)
	self:addAnimation("jump_d", {14,15,16,9}, .2, false)
	self:addAnimation("attack_eye", {18,19,20,21,22,23,24,17}, .2, false)
	self:addAnimation("attack_kick", {26,27,28,29,30,31,32,25}, .1, true)
	self:addAnimation("attack_arm_aim", {33,34,35,36,37,38}, .2, false)
	self:addAnimation("attack_arm_fire", {39,40,41}, .2, false)
	self:addAnimation("attack_arm_recover", {42,43,44,32}, .2, false)
	self:playAnimation("attack_kick")
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

--	function Boss2:hurt(Damage)
--		Sprite.hurt(self, Damage)
--		self:flicker(.1)
--	end

function Boss2:addWeapon(GunGroup, slot)
	self.weapons[slot] = GunGroup
end


function Boss2:doConfig()
	Enemy.doConfig(self)
	self:setCollisionBox(124,28,136,240)
	

	local gunRPG = Emitter:new(0,0)
	local ROCKETLIFESPAN = 10
	for j=1, 4 do
		--Create rockets
		local curRocket = HomingRocket:new(0,0)
		curRocket:doConfig()
		curRocket:lockTarget(GameState.playerShip)
		--local curRocket = Sprite:new(0,0, LevelManager:getParticle("bullet-red"))
		curRocket.attackPower = 1
		curRocket.lifeSpan = ROCKETLIFESPAN
		gunRPG:addParticle(curRocket)
		curRocket.killOffScreen = false
		GameState.enemyBullets:add(curRocket)
		GameState.destructables:add(curRocket)
		GameState.worldParticles:add(curRocket)
	end
	gunRPG:setSound(LevelManager:getSound("fire_2"))
	gunRPG:setSpeed(0, 10)
	gunRPG:setAngle(-150, 20)
	gunRPG:setRadial(true)
	gunRPG:lockParent(self, false, 99, 13)
	gunRPG:start(false, ROCKETLIFESPAN, 1, -1)
	gunRPG:stop()
	GameState.emitters:add(gunRPG)
	self:addWeapon(gunRPG, 1)
	
	--Weapon 2: Flamethrower
	local gunFlame = Emitter:new(0,0)
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

		gunFlame:addParticle(curParticle)
		GameState.enemyBullets:add(curParticle)
		GameState.worldParticles:add(curParticle)
	end
	gunFlame:setSpeed(800)
	gunFlame:setAngle(0,5)
	gunFlame:setGravity(-200)
	gunFlame:lockParent(self, false, 112, 26)
	gunFlame:setSound(LevelManager:getSound("fire_1"))
	--gunFlame:setCallback(self, PlayerMech.fireWeapon)
	gunFlame:start(false, .4, .06, -1)
	gunFlame:stop()
	GameState.emitters:add(gunFlame)
	self:addWeapon(gunFlame, 2)

	--Weapon 3: Railgun
	local gunLaser = Emitter:new(0,0)
	for i=1, 4 do
		local curRail = Railbeam:new(0,0)
		curRail:doConfig()
		curRail.color = {250,20,20}
		GameState.enemyBullets:add(curRail)
		gunLaser:addParticle(curRail)
	end
	gunLaser:setSpeed(1500)
	gunLaser:setAngle(180,1)
	gunLaser:setRadial(true)
	gunLaser:lockParent(self, false, 112, 26)
	gunLaser:setSound(LevelManager:getSound("railgun"))
	--gunLaser:setCallback(self, PlayerMech.fireWeapon)
	gunLaser:start(false, 2, .7, -1)
	gunLaser:stop()
	GameState.emitters:add(gunLaser)
	self:addWeapon(gunLaser, 3)
	
	--Weapon 4: Foot. Yes, this is a gun.
	local gunFoot = Emitter:new(0,0)
	local kickHitbox = Sprite:new(0,0)
	kickHitbox:createGraphic(130,64)
	kickHitbox.attackPower = 1
	kickHitbox.immovable = true
	GameState.enemyBullets:add(kickHitbox)
	gunFoot:setSound(LevelManager:getSound("hit_ground"))
	gunFoot:setSpeed(200)
	gunFoot:setAngle(180,0)
	gunFoot:setDrag(200,0)
	gunFoot:lockParent(self, false, 0,0)
	gunFoot:start(true, .5)
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
		--Move forwards
		
	elseif self.route == 2 then
		--Move backwards
		
	elseif self.route == 3 then
		--Attack (eye laser)
		
	elseif self.route == 4 then
		--Attack (flamethrower)
		
	elseif self.route == 5 then
		--Attack (missile)
		
	elseif self.route == 6 then
		--Attack (summon)
		
	elseif self.route == 7 then
		--Death
	
	end
	
	Sprite.update(self)
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
function Boss2:nextRoute()
	self.weapons[1]:stop()
	self.weapons[2]:stop()
	self.route = math.random(1, self.NUMROUTES)
	self.aiStage = 1
end

function Boss2:getType()
	return "Boss2"
end

return Boss2	
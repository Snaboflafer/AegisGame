--Class for sprites. Should extend Object
Boss1 = {
	weapons = {},
	aimAngle = 180,
	targetX = 512,
	targetY = 128
}
--Weapon1: Machine gun
--Weapon2: Rockets

function Boss1:new(X,Y,ImageFile)
	s = Enemy:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self
	
	s.NUMROUTES = 3
	s.route = 1
	s.health = 20
	s.maxHealth = 20
	s.score = 1000
	
	s.immovable = true
	GameState.bossHpBar.visible = true
	GameState.bossHpMask.visible = true
	return s
end

function Boss1:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
end

function Boss1:respawn(SpawnX, SpawnY)
	if SpawnY == nil then
		Enemy.respawn(self, SpawnX, General.screenH/2)
	else
		Enemy.respawn(self, SpawnX, SpawnY)
	end
end

--	function Boss1:hurt(Damage)
--		Sprite.hurt(self, Damage)
--		self:flicker(.1)
--	end

function Boss1:addWeapon(Gun, slot)
	self.weapons[slot] = Gun
end

function Boss1:doConfig()
	Enemy.doConfig(self)
	self:setCollisionBox(32, 44, 244, 48)
	
	--self:setScale(5,5)

	local gunMG = Emitter:new(0,0)
	for j=1, 20 do
		--Create bullets
		local curBullet = Sprite:new(0,0, LevelManager:getParticle("bullet_small"))
		curBullet.attackPower = 1
		gunMG:addParticle(curBullet)
		GameState.enemyBullets:add(curBullet)
	end
	gunMG:setSpeed(300, 350)
	gunMG:lockParent(self, false, 14, 45)
	gunMG:setAngle(self.aimAngle, 10)
	gunMG:start(false, 10, .3, -1)
	GameState.emitters:add(gunMG)
	self:addWeapon(gunMG, 1)



	local gunRPG = Emitter:new(0,0)
	for j=1, 10 do
		--Create bullets
		local curBullet = Sprite:new(0,0, LevelManager:getParticle("bullet-red"))
		curBullet.attackPower = 1
		gunRPG:addParticle(curBullet)
		GameState.enemyBullets:add(curBullet)
	end
	gunRPG:setSpeed(100, 150)
	gunRPG:lockParent(self, false, 99, 13)
	gunRPG:start(false, 10, .2, -1)
	gunRPG:stop()
	GameState.emitters:add(gunRPG)
	self:addWeapon(gunRPG, 2)

	--Thruster particles
	local enemyThruster = Emitter:new(0,0)
	for j=1, 5 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("thruster"), 16, 8)
		curParticle:addAnimation("default", {1,2,3,4}, .025, false)
		curParticle:playAnimation("default")
		curParticle:setScale(5,5)
		enemyThruster:addParticle(curParticle)
	end
	enemyThruster:setSpeed(100, 200)
	enemyThruster:setAngle(0, 30)
	enemyThruster:lockParent(self, true, 155, 28)
	enemyThruster:start(false, .1, 0)

	--Register emitter, so that it will be updated
	GameState.emitters:add(enemyThruster)
end

function Boss1:kill()
	Enemy.kill(self)
	self.weapons[1]:stop()
	self.weapons[2]:stop()
	GameState.bossHpBar.visible = false
	GameState.bossHpMask.visible = false
end

function Boss1:update()
	self:updateHealth()
	if self.route == 1 then
		self.targetX = General.screenW * .75
		self.targetY = General.screenH * .4
		self.weapons[1]:setAngle(180, 0)
		if self.lifetime > 4 then
			self.lifetime = 0
			self.route = 2
		end
	elseif self.route == 2 then
		self.targetX = General.screenW * .6
		self.targetY = General.screenH * .6
		if self.lifetime < 2 then
			self.weapons[1]:setAngle(200 + math.sin(self.lifetime)*10, 0)
		elseif self.lifetime < 4 then
			self.weapons[1]:setAngle(180,0)
		else
			self.lifetime = 0
			self.route = 3
			self.weapons[1]:stop()
			self.weapons[2]:restart()
		end
	elseif self.route == 3 then
		self.targetX = General.screenW * .8
		self.targetY = General.screenH * .4
		self.weapons[2]:lockTarget(GameState.player, 15)

		if self.lifetime > 2 then
			self.lifetime = 0
			self.route = 0
			self.weapons[2]:stop()
			self.weapons[1]:restart()
		end
	end

	self.velocityX = General:getCamera().x + self.targetX - self.x
	self.velocityY = General:getCamera().y + self.targetY - self.y + 10*math.sin(self.lifetime)

	self:playAnimation("idle")
	

	Sprite.update(self)
end

function Boss1:updateHealth()
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

function Boss1:getType()
	return "Boss1"
end

return Boss1	
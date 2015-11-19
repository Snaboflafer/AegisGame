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
	s.health = 50
	s.maxHealth = 50
	s.score = 1000
	s.massless = false
	
	s.weapons = {}
	
	s.immovable = true
	GameState.bossHpBar.visible = true
	GameState.bossHpMask.visible = true
	return s
end

function Boss1:setAnimations()
	self:addAnimation("default", {1}, 0, false)
end

function Boss1:respawn(SpawnX, SpawnY)
	SoundManager:playBgm("sounds/music/Zenon.ogg")
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
	self:setCollisionBox(32, 34, 244, 70)
	
	--self:setScale(5,5)

	self.immovable = true
	
	local gunMG = Emitter:new(0,0)
	for j=1, 20 do
		--Create bullets
		local curBullet = Sprite:new(0,0, LevelManager:getParticle("bullet_small"))
		curBullet.attackPower = .2
		curBullet.massless = true
		gunMG:addParticle(curBullet)
		GameState.enemyBullets:add(curBullet)
	end
	gunMG:setSound(LevelManager:getSound("fire_1"))
	gunMG:setSpeed(300, 350)
	gunMG:lockParent(self, false, 14, 45)
	gunMG:setAngle(self.aimAngle, 10)
	gunMG:start(false, 10, .3, -1)
	GameState.emitters:add(gunMG)
	self:addWeapon(gunMG, 1)

	local gunRPG = Emitter:new(0,0)
	for j=1, 4 do
		--Create rockets
		local curRocket = HomingRocket:new(0,0)
		curRocket:doConfig()
		curRocket:lockTarget(GameState.playerShip)
		--local curRocket = Sprite:new(0,0, LevelManager:getParticle("bullet-red"))
		curRocket.attackPower = 1
		gunRPG:addParticle(curRocket)
		GameState.enemyBullets:add(curRocket)
	end
	gunRPG:setSound(LevelManager:getSound("fire_2"))
	gunRPG:setSpeed(0, 10)
	gunRPG:setAngle(180, 5)
	gunRPG:setRadial(true)
	gunRPG:lockParent(self, false, 99, 13)
	gunRPG:start(false, 10, .5, -1)
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
	
	self:nextRoute()
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
		if self.aiStage == 1 then
			--Initialize
			self.weapons[1]:setAngle(180, 0)
			self.weapons[1]:start(false, 10, .15, 10)
			self.weapons[1]:stop()
			Timer:new(1, self, Boss1.updateStage)
			self:updateStage()
		elseif self.aiStage == 2 then
			--Travel (1)
			self.targetX = General.screenW * .75
			self.targetY = General.screenH * .2
		elseif self.aiStage == 3 then
			--Fire (1)
			self.weapons[1]:restart()
			Timer:new(2, self, Boss1.updateStage)
			self:updateStage()
		elseif self.aiStage == 4 then
			--Firing (1)
		elseif self.aiStage == 5 then
			self.weapons[1]:stop()
			Timer:new(1, self, Boss1.updateStage)
			self:updateStage()
		elseif self.aiStage == 6 then
			--Travel (2)
			self.targetY = General.screenH * .4
		elseif self.aiStage == 7 then
			--Fire (2)
			self.weapons[1]:restart()
			Timer:new(2, self, Boss1.updateStage)
			self:updateStage()
		elseif self.aiStage == 8 then
			--Firing (2)
		elseif self.aiStage == 9 then
			self.weapons[1]:stop()
			Timer:new(1, self, Boss1.updateStage)
			self:updateStage()
		elseif self.aiStage == 10 then
			--Travel (3)
			self.targetY = General.screenH * .6
		elseif self.aiStage == 11 then
			--Fire (3)
			self.weapons[1]:restart()
			Timer:new(2, self, Boss1.updateStage)
			self:updateStage()
		elseif self.aiStage == 12 then
			--Firing (3)
		elseif self.aiStage == 13 then
			self:nextRoute()
		end
	elseif self.route == 2 then
		if self.aiStage == 1 then
			self.weapons[1]:start(false, 10, .1, -1)
			self.targetX = General.screenW * .6
			self.targetY = General.screenH * .2
			Timer:new(4, self, Boss1.updateStage)
			self.lifetime = 0
			self:updateStage()
		elseif self.aiStage == 2 then
			self.weapons[1]:setAngle(200 + math.cos(self.lifetime)*30, 5)
		elseif self.aiStage == 3 then
			self:nextRoute()
		end
	elseif self.route == 3 then
		if self.aiStage == 1 then
			self.targetX = General.screenW * .8
			self.targetY = General.screenH * .4
			Timer:new(2, self, Boss1.updateStage)
			self:updateStage()
			love.audio.newSource(LevelManager:getSound("charge")):play()
		elseif self.aiStage == 2 then
			--Travel
		elseif self.aiStage == 3 then
			--self.weapons[2]:setAngle(90, 0)
			self.weapons[2]:restart()
			Timer:new(2, self, Boss1.updateStage)
			self:updateStage()
		elseif self.aiStage == 4 then
			--Firing
		elseif self.aiStage == 5 then
			self:nextRoute()
		end
	else
		--Default (determine a route)
		self:nextRoute()
	end

	self.velocityX = 1.5*(General:getCamera().x + self.targetX - self.x) + 15*math.cos(self.lifetime)
	self.velocityY = 1.5*(General:getCamera().y + self.targetY - self.y) + 10*math.sin(self.lifetime)

	self:playAnimation("default")
	
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
function Boss1:nextRoute()
	self.weapons[1]:stop()
	self.weapons[2]:stop()
	self.route = math.random(1, self.NUMROUTES)
	self.aiStage = 1
end

function Boss1:getType()
	return "Boss1"
end

return Boss1	
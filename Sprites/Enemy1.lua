--Class for sprites. Should extend Object
Enemy1 = {
}

function Enemy1:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.NUMROUTES = 3
	s.route = math.floor(math.random() * s.NUMROUTES)
	s.health = 1
	s.maxHealth = 1
	s.score = 100
	s.attackPower = 1
	s.maxVelocityX = 150
	s.maxVelocityY = 100
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy1:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, true)
	self:addAnimation("down", {5,6}, .1, true)
	self:playAnimation("idle")
end

function Enemy1:respawn(SpawnX, SpawnY)
	if SpawnY == nil then
		Enemy.respawn(self, SpawnX, General.screenH/3 + 256*(math.random()-.5))
	else
		Enemy.respawn(self, SpawnX, SpawnY)
	end
	self.accelerationX = 0
	self.accelerationY = 0
	self.aiStage = 0
end

function Enemy1:doConfig()
	Enemy.doConfig(self)
	self:setCollisionBox(7,26,44,19)
	
	--Create enemy gun
	local enemyGun = Emitter:new(0,0)
	for j=1, 2 do
		--Create bullets
		local curBullet = Sprite:new(0,0, LevelManager:getParticle("bullet-red"))
		curBullet.attackPower = 1
		enemyGun:addParticle(curBullet)
		GameState.enemyBullets:add(curBullet)
	end
	enemyGun:setSpeed(100, 150)
	enemyGun:lockParent(self, true, 0)
	--enemyGun:lockTarget(self.player)		(Use this to target the player)
	enemyGun:setAngle(180, 0)
	enemyGun:addDelay(2 + math.random())
	enemyGun:start(false, 10, 2, -1)
	--curEnemy:addChild(enemyGun)

	--Thruster particles
	local enemyThruster = Emitter:new(0,0)
	for j=1, 10 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("thruster"), 16, 8)
		curParticle:addAnimation("default", {1,2,3,4}, .025, false)
		curParticle:playAnimation("default")
		enemyThruster:addParticle(curParticle)
	end
	enemyThruster:setSpeed(50, 60)
	enemyThruster:setAngle(0, 30)
	enemyThruster:lockParent(self, true, self.width-4, self.height/2 - 3)
	enemyThruster:start(false, .1, 0)

	GameState.emitters:add(enemyGun)
	GameState.emitters:add(enemyThruster)
end

function Enemy1:update()
	if self.aiStage == 0 then
		if not self:onScreen() then
			Enemy.update(self)
			return
		else
			self.aiStage = 1
		end
	end
	
	if self.route == 1 then
		self.velocityY = 100*math.cos(2*self.lifetime)
		self.velocityX = -50
	elseif self.route == 2 then
		if self.lifetime < 2 then
			self.accelerationY = -50
		else
			self.accelerationY = 15
			self.accelerationX = -60
		end
	elseif self.route == 3 then
		if self.lifetime < 2 then
			self.accelerationY = 50
		else
			self.accelerationY = -15
			self.accelerationX = -60
		end
	end
	
	if self.velocityY < 50 then
		self:playAnimation("up")
	elseif self.velocityY > 50 then
		self:playAnimation("down")
	else
		self:playAnimation("idle")
	end
	
	Enemy.update(self)
end

function Enemy1:getType()
	return "Enemy1"
end

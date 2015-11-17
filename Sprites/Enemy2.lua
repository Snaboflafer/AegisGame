--Class for sprites. Should extend Object
Enemy2 = {
	maxVelocityX = 100,
	weapon = {}
}

function Enemy2:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.aiStage = 1
	s.health = 2
	s.maxHealth = 2
	s.score = 200
	s.NUMROUTES = 1
	s.attackPower = 1
	--s.accelerationY = 200
	s.y = General.screenH - 200
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy2:setAnimations()
	self:addAnimation("idle_0",   {1,2}, .1, true)
	self:addAnimation("fire_0",  {3}, .5, false)
	self:addAnimation("idle_10",  {4,5}, .1, true)
	self:addAnimation("fire_10", {6}, .5, false)
	self:addAnimation("idle_20",  {7,8}, .1, true)
	self:addAnimation("fire_20", {9}, .5, false)
	self:addAnimation("idle_30",  {10,11}, .1, true)
	self:addAnimation("fire_30", {12}, .5, false)
	self:addAnimation("idle_35",  {13,14}, .1, true)
	self:addAnimation("fire_35", {15}, .5, false)
end

function Enemy2:respawn(SpawnX, SpawnY)
	if SpawnY == nil then
		Enemy.respawn(self, SpawnX, General.screenH-120)
	else
		Enemy.respawn(self, SpawnX, SpawnY)
	end
end

function Enemy2:doConfig()
	Enemy.doConfig(self)
	self:setCollisionBox(40, 48, 122, 65)

	--Create gun
	self.weapon = Emitter:new(0, 0)
	for j=1, 2 do
		--Create bullets
		local curBullet = Sprite:new(0, 0, LevelManager:getParticle("bullet-red"))
		curBullet.attackPower = 1
		self.weapon:addParticle(curBullet)
		GameState.enemyBullets:add(curBullet)
	end
	self.weapon:setSpeed(300, 350)
	self.weapon:start(false, 10, 1, -1)
	self.weapon:setOffset(58)
	self.weapon:stop()
	self.weapon:lockParent(self, true, 51, -4)
	GameState.emitters:add(self.weapon)
end

function Enemy2:update()
	self.weapon:lockTarget(GameState.player, 0, GameState.player.velocityX/3)
	fireAngle = self.weapon:getAngle()
	fireAngle = fireAngle * 180 / math.pi
	fireAngle = 180 - fireAngle
	if self.aiStage == 1 then
		--Move to firing point
		if self:getScreenX() <= General.screenW - 200 then
			self:updateStage()
			Timer:new(8, self, Enemy.updateStage)
			self.weapon:restart()
		end
		if fireAngle < 10 then
			self:playAnimation("idle_0")
		elseif fireAngle < 20 then
			self:playAnimation("idle_10")
		elseif fireAngle < 30 then
			self:playAnimation("idle_20")
		elseif fireAngle < 35 then
			self:playAnimation("idle_30")
		elseif fireAngle < 90 then
			self:playAnimation("idle_35")
		else
			self:playAnimation("idle_0")
		end
		
	elseif self.aiStage == 2 then
		--self.weapon:setAngle(180 - weaponAngle, 0)
		self.x = General:getCamera().x + General.screenW - 200
		if fireAngle < 10 then
			self:playAnimation("idle_0")
		elseif fireAngle < 20 then
			self:playAnimation("idle_10")
		elseif fireAngle < 30 then
			self:playAnimation("idle_20")
		elseif fireAngle < 35 then
			self:playAnimation("idle_30")
		elseif fireAngle < 90 then
			self:playAnimation("idle_35")
		else
			self:playAnimation("idle_0")
		end
	else
		s.velocityX = 10
		self.weapon:stop()
		self:playAnimation("idle_0")
	end
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Enemy.update(self)
end

function Enemy2:getType()
	return "Enemy2"
end

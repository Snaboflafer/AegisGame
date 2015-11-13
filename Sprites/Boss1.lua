--Class for sprites. Should extend Object
Boss1 = {
	weapons = {}
}

function Boss1:new(X,Y,ImageFile)
	s = Enemy:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self
	
	s.NUMROUTES = 0
	s.route = 0
	s.health = 20
	s.maxHealth = 20
	s.score = 1000
	
	s.immovable = true
	
	return s
end

function Boss1:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, true)
	self:addAnimation("down", {5,6}, .1, true)
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

function Boss1:addWeapon(GunGroup, slot)
	self.weapons[slot] = GunGroup
end


function Boss1:doConfig()
	Enemy.doConfig(self)
	self:setCollisionBox(7, 26, 44, 19)
	
	self:setScale(5,5)

	local bossGuns1 = Group:new()
	--Create enemy gun
	for i=1, 3 do
		local enemyGun = Emitter:new(0,0)
		for j=1, 10 do
			--Create bullets
			local curBullet = Sprite:new(0,0, LevelManager:getParticle("bullet-red"))
			curBullet.attackPower = 1
			enemyGun:addParticle(curBullet)
			GameState.enemyBullets:add(curBullet)
		end
		enemyGun:setSpeed(100, 150)
		enemyGun:lockParent(self, false, 0)
		--enemyGun:lockTarget(self.player)		(Use this to target the player)
		enemyGun:setAngle(140+20*i, 0)
		enemyGun:start(false, 10, .8, -1)
		GameState.emitters:add(enemyGun)
		bossGuns1:add(enemyGun)
	end
	self:addWeapon(bossGuns1, 1)

	local bossGuns2 = Group:new()
	--Create enemy gun
	for i=0, 3 do
		local enemyGun = Emitter:new(0,0)
		for j=1, 10 do
			--Create bullets
			local curBullet = Sprite:new(0,0, LevelManager:getParticle("bullet-red"))
			curBullet.attackPower = 1
			enemyGun:addParticle(curBullet)
			GameState.enemyBullets:add(curBullet)
		end
		enemyGun:setSpeed(100, 150)
		enemyGun:lockParent(self, false, i*20, 80)
		--enemyGun:lockTarget(self.player)		(Use this to target the player)
		enemyGun:setAngle(140+20*i, 0)
		enemyGun:start(false, 10, .8, -1)
		enemyGun:stop()
		GameState.emitters:add(enemyGun)
		bossGuns2:add(enemyGun)
	end
	self:addWeapon(bossGuns2, 2)

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
	enemyThruster:setSpeed(50, 60)
	enemyThruster:setAngle(0, 30)
	enemyThruster:lockParent(self, true, self.width-20, self.height/2 - 3)
	enemyThruster:start(false, .1, 0)

	--Register emitter, so that it will be updated
	GameState.emitters:add(enemyThruster)
end

function Boss1:kill()
	Enemy.kill(self)
	for k, v in pairs(self.weapons[1].members) do 
		v:stop()
	end
	for k, v in pairs(self.weapons[2].members) do 
		v:stop()
	end
end

function Boss1:update()
	local target = 0

	if self.route == 0 then 
		target = General.screenW*3/4;
		i = 0
		for k, v in pairs(self.weapons[1].members) do 
			v:setAngle(120+self.lifetime*15 + i*10, 0)
		i = i + 1
		end
		if self.lifetime > 8 then
			self.lifetime = 0
			self.route = 1
		end
	elseif self.route == 1 then
		target = General.screenW*3/4;
		if self.lifetime < 4 then
			i = 0
			for k, v in pairs(self.weapons[1].members) do 
				v:setAngle(100 + self.lifetime*12 + i*50, 0)
				i = i + 1
			end
		elseif self.lifetime < 8 then
			i = 0
			for k, v in pairs(self.weapons[1].members) do 
				v:setAngle(self.lifetime*40 + i*10 - 60, 0)
				i = i + 1
			end
		else
			self.lifetime = 0
			self.route = 2
			for k, v in pairs(self.weapons[1].members) do 
				v:stop()
			end
			for k, v in pairs(self.weapons[2].members) do 
				v:restart()
				v:setAngle(270, 0)
			end
		end
	elseif self.route == 2 then
		target = General.screenW*1/4;
		if self.lifetime > 8 then
			self.lifetime = 0
			self.route = 1
			for k, v in pairs(self.weapons[2].members) do 
				v:stop()
			end
			for k, v in pairs(self.weapons[1].members) do 
				v:restart()
			end
		end
	end

	self.velocityX = 2*(General:getCamera().x + target - self.x)

	if self.velocityY < 50 then
		self:playAnimation("up")
	elseif self.velocityY > 50 then
		self:playAnimation("down")
	else
		self:playAnimation("idle")
	end
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Sprite.update(self)
end

function Boss1:getType()
	return "Boss1"
end

return Boss1	
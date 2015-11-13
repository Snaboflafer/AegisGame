--Class for third type of enemy sprites
Enemy3 = {
}

function Enemy3:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.route = 1
	s.health = 4
	s.maxHealth = 0
	s.score = 50
	s.NUMROUTES = 1
	s.attackPower = 1
	s.maxVelocityY = 200
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy3:setAnimations()
	self:addAnimation("idle", {1,2,3,4}, .02, true)
	self:addAnimation("forward", {5,6,7,8}, .02, true)
end

function Enemy3:respawn(SpawnX, SpawnY)
	if SpawnY == nil then
		Enemy.respawn(self, SpawnX, General.screenH/3 + 256*(math.random()-.5))
	else
		Enemy.respawn(self, SpawnX, SpawnY)
	end
	self.accelerationX = 0
	self.accelerationY = 0
end

function Enemy3:doConfig()
	Enemy.doConfig(self)
	
	self:setCollisionBox(45,18, 42,32)
end

function Enemy3:update()
	if self.aiStage == 1 then
		if self:getScreenX() <= General.screenW - 150 then
			self.aiStage = self.aiStage + 1
		end
	elseif self.aiStage == 2 then
		self.velocityX = GameState.cameraFocus.velocityX

		if math.abs(self.y - GameState.player.y) < 20 then
			self.aiStage = 3
		elseif self.y < GameState.player.y then
			self.accelerationY = 100
		elseif self.y > GameState.player.y then
			self.accelerationY = -100
		end
	else
		self.accelerationX = -500
		self.velocityY = 0
	end

	if self.velocityX < 0 then
		self:playAnimation("forward")
	else
		self:playAnimation("idle")
	end
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Enemy.update(self)
end

function Enemy3:getType()
	return "Enemy3"
end

--Class for third type of enemy sprites
Enemy4 = {
}

function Enemy4:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.health = 4
	s.maxHealth = 0
	s.score = 50
	s.NUMROUTES = 1
	s.attackPower = 1
	s.maxVelocityY = 200
	--s.accelerationY = 50
	s.y = General.screenH - 142
	s.immovable = true
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy4:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
	self:addAnimation("blink", {1,2,1}, .2, true)
	self:addAnimation("detonate", {2,3,4,5,6,7,8,9,10,11,12,13,14,5,2}, .03, false)
end

function Enemy4:respawn(SpawnX, SpawnY)
	if SpawnY == nil then
		Enemy.respawn(self, SpawnX, General.screenH-142)
	else
		Enemy.respawn(self, SpawnX, SpawnY)
	end
	self.accelerationX = 0
	self.accelerationY = 0
end

function Enemy4:doConfig()
	Enemy.doConfig(self)

	self:setCollisionBox(13,16, 86,37)
end

function Enemy4:respawn(SpawnX, SpawnY)
	Enemy.respawn(self, SpawnX, SpawnY)
	self.y = General.screenH - 150
end 

function Enemy4:update()

	xCenter, yCenter = self:getCenter()
	PRIME_DISTANCE = 300
	DETONATE_DISTANCE = 150

	if self.aiStage == 1 then
		-- Mine is idle
		self:playAnimation("idle")
		if math.abs(GameState.player.x - xCenter) <= PRIME_DISTANCE 
			and math.abs(GameState.player.y- yCenter) <= PRIME_DISTANCE then
			self.aiStage = self.aiStage + 1;
		end

	elseif self.aiStage == 2 then
		-- Mine is armed now
		self:playAnimation("blink")

		if math.abs(GameState.player.x - xCenter) <= DETONATE_DISTANCE
			and math.abs(GameState.player.y- yCenter) <= DETONATE_DISTANCE then
			self.aiStage = self.aiStage + 1;
		end

	elseif self.aiStage == 3 then
		-- Mine is detonating
		self:playAnimation("detonate")
		if self.animFinished then
			self:setCollisionBox(
				13 - DETONATE_DISTANCE,
		 		16 - DETONATE_DISTANCE,
		  		86 + 2 * DETONATE_DISTANCE,
		   		37 + DETONATE_DISTANCE)

			-- Mine pop
			self.velocityY = -1000
			self.accelerationY = 1000
			Timer:new(0.1, self, self.kill)
		end
	end
	
	-- Mine is off the screen and no longer exists
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Enemy.update(self)
end

function Enemy4:getType()
	return "Enemy4"
end

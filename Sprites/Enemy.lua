--Class for sprites. Should extend Object
Enemy = {
	massless = true,
	route = 0,
	NUMROUTES = 0,
	attackPower = 1,
	score = 0,
	aiStage = 1
}

function Enemy:new(X,Y)
	s = Sprite:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy:kill()
	GameState.explosion:play(self.x + self.width / 2, self.y + self.height / 2)
	Enemy:addToScore(self.score)
	self:spawnPickup()
	Sprite.kill(self)
end

function Enemy:hurt(Damage)
	Sprite.hurt(self, Damage)
	self:flash({243, 17,17}, .2)
	self.sfxHurt:play()
end

function Enemy:addToScore(score)
	GameState.score = GameState.score + score
end

function Enemy:respawn(SpawnX, SpawnY)
	self.lifetime = 0
	self.health = self.maxHealth
	self.x = SpawnX
	self.y = SpawnY
	self.route = math.random(1, self.NUMROUTES)
	self.velocityX = 0
	self.velocityY = 0
	self.exists = true
	self.aiStage = 1
end

function Enemy:doConfig()
	self:setAnimations()
	self:lockToScreen(Sprite.UPDOWN)
end

function Enemy:update()
	Sprite.update(self)
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end
end

function Enemy:updateStage()
	self.aiStage = self.aiStage + 1
end

function Enemy:spawnPickup()
	GameState.pickups:add(Pickup:new(self.x + self.width/2,self.y + self.height/2,math.random(1,Pickup.NUM_PICKUPS)))
end

function Enemy:getType()
	return "Enemy"
end

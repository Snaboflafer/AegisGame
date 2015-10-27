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
	GameState.explosion:play(self.x, self.y)
	Enemy:addToScore(self.score)
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
	self.route = math.floor(math.random()*self.NUMROUTES)
	self.velocityX = 0
	self.velocityY = 0
	self.accelerationX = 0
	self.accelerationY = 0
	self.exists = true
	self.aiStage = 1
end


function Enemy:update()
	Sprite.update(self)
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end
end

function Enemy:getType()
	return "Enemy"
end

--Class for sprites. Should extend Object
Enemy = {
	pointValue = 0,
	massless = true,
	emitterGun = nil,
	emitterThruster = nil,
	attackTimer = .1
}

function Enemy:new(X,Y,ImageFile)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.maxVelocityX = 150
	s.maxVelocityY = 150
	
	return s
end

function Enemy:respawn(SpawnX, SpawnY)
	self.x = SpawnX
	self.y = SpawnY
	self.velocityX = 0
	self.velocityY = 0
	self.accelerationX = 0
	self.accelerationY = 0
	self.exists = true
end

function Enemy:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, true)
	self:addAnimation("down", {5,6}, .1, true)
end

function Enemy:setGun(BulletEmitter)
	self.emitterGun = BulletEmitter
	self.emitterGun:setSpeedRange(300,500)
end

function Enemy:setPointValue(V)
	self.pointValue = V
end

function Enemy:getPointValue()
	return self.pointValue
end

function Enemy:update()
	self.attackTimer = self.attackTimer - General.elapsed
	if self.attackTimer <= 0 then
		self.attackTimer = .1
		--local aimX, aimY = GameState.player:getCenter()
		--local dx = self.x - aimX
		--local dy = aimY - self.y
		self.emitterGun:setPosition(self.x, self.y)
		--self.emitterGun:setAngle(math.atan(dy/dx), 0)

		local playerX, playerY = GameState.player:getCenter()
		self.emitterGun:setTarget(playerX, playerY, 0)
		self.emitterGun:start(false, 5)
	end

	--self:shootBullet(GameState.player:getCenter())
	self.accelerationX = (math.random() - 0.5)*1000
	self.accelerationY = (math.random() - 0.5)*1000
	
	
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

function Enemy:getType()
	return "Enemy"
end

return Enemy	
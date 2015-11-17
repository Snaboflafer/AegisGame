
HomingRocket = {
	THRUST = 100,
	TURNSPEED = 10,
	angle = 0,
	target = nil,
	targetOffsetX = 0,
	targetOffsetY = 0,
}

function HomingRocket:new(X, Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self
	
	s.NUMROUTES = 1
	s.route = 1
	s.health = 0
	s.maxHealth = 0
	s.score = 50
	s.attackPower = 1
	
	return s
end

function HomingRocket:setAnimations()
	--No animations to set
	return
end

function HomingRocket:respawn(SpawnX, SpawnY)
	Enemy.respawn(self, SpawnX, SpawnY)
	self.accelerationX = 0
	self.accelerationY = 0
	self.velocityX = 0
	self.velocityY = 0
end

function HomingRocket:doConfig()
	Enemy.doConfig(self)
	self:loadImage("images/particles/rocket.png")
	self:setCollisionBox(12, 0, 12, 12)
end

function HomingRocket:update()
	--	if math.random() < .01 then
	--		GameState.explosion:play(self.x, self.y)
	--	end
	self.angle = math.atan(self.velocityY/self.velocityX)
	
	Enemy.update(self)
end
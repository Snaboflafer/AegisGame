
HomingRocket = {
	THRUST = 500,
	TURNSPEED = 600,
	maxSpeed = 200,
	target = nil,
	targetX = 0,
	targetY = 0,
	targetOffsetX = 0,
	targetOffsetY = 0,
	fireTrail = nil
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
	self.originX = self.width/2
	self.originY = self.height/2
	
	self.maxVelocityX = self.maxSpeed * 2^(1/2)
	self.maxVelocityY = self.maxSpeed * 2^(1/2)
	
	self.fireTrail = Emitter:new()
	for i=1, 20 do
		--Create the actual trail sprites
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("fireTrail"), 16, 16)
		curParticle:addAnimation("default", {1,2,3,4,5,6,7,7,8,8,9,9,9,10}, .01, false)
		curParticle:playAnimation("default")
		self.fireTrail:addParticle(curParticle)
	end
	--Set fire trail parameters
	self.fireTrail:setSpeed(10)
	self.fireTrail:lockParent(self, true, self.width/2-8, self.height/2-8)
	--self.fireTrail:setRadial(true)
	self.fireTrail:setOffset(16)
	self.fireTrail:start(false, .2, .01, -1)
	GameState.emitters:add(self.fireTrail)
end

function HomingRocket:lockTarget(Target, OffsetX, OffsetY)
	self.target = Target
	self.targetOffsetX = OffsetX or Target.width/2
	self.targetOffsetY = OffsetY or Target.height/2
end
function HomingRocket:setTarget(TargetX, TargetY)
	self.targetX = TargetX
	self.targetY = TargetY
	self.target = nil
end


function HomingRocket:update()

	if self.target ~= nil then
		self.targetX = self.target.x + self.targetOffsetX
		self.targetY = self.target.y + self.targetOffsetY
	end
	
	local targetAngle = math.atan2(self.targetY-self.y,self.targetX - self.x)
	
	if (targetAngle-self.angle+math.pi) % (2*math.pi) - math.pi > 0 then
		self.angle = self.angle + (self.TURNSPEED * General.elapsed) * math.pi/180
	else
		self.angle = self.angle - (self.TURNSPEED * General.elapsed) * math.pi/180
	end
	
	self.accelerationX = self.THRUST * math.cos(self.angle)
	self.accelerationY = self.THRUST * math.sin(self.angle)

	self.fireTrail:setAngle((math.pi-self.angle) * 180/math.pi, 5)

	Enemy.update(self)
end

function HomingRocket:getType()
	return "HomingRocket"
end
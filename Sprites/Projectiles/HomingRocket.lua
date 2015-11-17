
HomingRocket = {
	THRUST = 50,
	TURNSPEED = 90,
	maxSpeed = 200,
	target = nil,
	targetX = 0,
	targetY = 0,
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
	self.offsetX = self.width/2
	self.offsetY = self.height/2
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
	
	--self.angle = math.atan(self.velocityY/self.velocityX)
	local targetAngle = math.atan2(self.y - self.targetY,self.targetX - self.x)

	--if self.angle < targetAngle then
	--	self.angle = self.angle + (self.TURNSPEED * General.elapsed)
	--elseif self.angle > targetAngle then
	--	self.angle = self.angle - (self.TURNSPEED * General.elapsed)
	--end
	self.angle = self.angle + General.elapsed * self.TURNSPEED * math.pi/180
	--if self.targetX < self.x then
	--	self.accelerationX = -self.THRUST * math.cos(self.angle)
	--elseif self.targetX > self.x then
	--	self.accelerationX = self.THRUST * math.cos(self.angle)
	--end
	--if self.targetY < self.y then
	--	self.accelerationY = -self.THRUST * math.sin(self.angle)
	--elseif self.targetY > self.y then
	--	self.accelerationY = self.THRUST * math.sin(self.angle)
	--end
	
	
	Enemy.update(self)
end

function HomingRocket:getType()
	return "HomingRocket"
end
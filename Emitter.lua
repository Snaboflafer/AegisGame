
Emitter = {
	x = 0,
	y = 0,
	gravity = 0,
	drag = 0,
	emitAngle = 0,
	angleRange = 2*math.pi,
	velocityMin = 0,
	velocityMax = 100,
	emitDelay = 0,
	emitTimer = 0,
	emitCount = 1,
	launchAll = true,
	enabled = false,
	lifetime = 120,
	parent = nil,
	parentOffsetX = 0,
	parentOffsetY = 0
}

function Emitter:new(X, Y)
	s = Group:new()
	setmetatable(s, self)
	setmetatable(self, Group)
	self.__index = self
	
	s.x = X or 0
	s.y = Y or 0
	
	return s
end

--[[ Start the emitter
	LaunchAll	Boolean, whether to launch all particles at once or sequentially
	Lifetime	How long each particle lasts in seconds (default 1min)
	Delay		Delay for sequential launch between particles
--]]
function Emitter:start(LaunchAll, Lifetime, Delay)
	if LaunchAll == nil then
		LaunchAll = true
	end
	self.launchAll = launchAll
	self.lifetime = Lifetime or 120
	self.emitDelay = Delay or 0
	self.emitTimer = 0
	self.enabled = true
end

function Emitter:stop()
	self.enabled = false
end

function Emitter:addParticle(NewParticle)
	NewParticle.exists = false
	self:add(NewParticle)
end

function Emitter:update()
	for i=1, self:getSize() do
		if self.members[i].lifetime > self.lifetime then
			self.members[i].exists = false
		end
		if not self.members[i]:onScreen() then
			self.members[i].exists = false
		end
	end
	
	Group.update(self)
	
	--Emission
	if not self.enabled then
		return
	end
	
	if self.launchAll then
		self.enabled = false
		
		for i=1, self:getSize(), 1 do
			self:emitParticle()
		end
	else
		self.emitTimer = self.emitTimer - General.elapsed
		if self.emitTimer > 0 then
			return
		end
		
		self:emitParticle()
		self.emitTimer = self.emitDelay
	end
end

function Emitter:draw()
	Group.draw(self)
end

function Emitter:emitParticle()
	if self.parent ~= nil then
		self.x = self.parent.x + self.parentOffsetX
		self.y = self.parent.y + self.parentOffsetY
	end

	
	local particle = self:getFirstAvailable(true)
	
	if particle == nil then
		return
	end
	
	particle.lifetime = 0
	particle.x = self.x
	particle.y = self.y
	particle.accelerationY = self.gravity
	particle.dragX = self.drag
	particle.dragY = self.drag
	particle.exists = true
	particle.alive = true
	particle.visible = true

	local velocity = math.random(self.velocityMin, self.velocityMax)
	local angle = math.random(self.emitAngle - self.angleRange, self.emitAngle + self.angleRange)
	particle.velocityX = velocity * math.cos(angle)
	particle.velocityY = -velocity * math.sin(angle)
end

function Emitter:setPosition(X, Y)
	self.x = X or 0
	self.y = Y or 0
end
function Emitter:setAngle(Angle, Range)
	self.emitAngle = Angle
	self.angleRange = Range % (2*math.pi) or 0
end
function Emitter:setTarget(TargetX, TargetY, Range)
	local dx = TargetX - self.x
	local dy = self.y - TargetY
	self.emitAngle = math.atan2(dy, dx)
	
	self.angleRange = Range or 0
end
function Emitter:setSpeedRange(Min, Max)
	self.velocityMin = Min
	self.velocityMax = Max
end
function Emitter:setParticleGravity(Gravity)
	self.gravity = Gravity
end
function Emitter:setParticleDrag()
	self.drag = Drag
end
function Emitter:setParent(Object, offsetX, offsetY)
	self.parent = Object
	self.parentOffsetX = 0
	self.parentOffsetY = 0
end

function Emitter:getType()
	return "Emitter"
end
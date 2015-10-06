
Emitter = {
	x = 0,
	y = 0,
	gravity = 0,
	drag = 0,
	emitAngle = 0,
	angleRange = 360,
	velocityMin = 0,
	velocityMax = 100,
	emitDelay = 0,
	emitTimer = 1,
	emitCount = 1,
	launchAll = true,
	enabled = false,
	lifetime = 120
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
	self.launchAll = LaunchAll
	self.lifetime = Lifetime
	self.emitDelay = Delay
	self.emitTimer = 0
	self.enabled = true
end

function Emitter:stop()
	self.enabled = false
end

function Emitter:addParticle(NewParticle)
	self:add(NewParticle)
end

function Emitter:update()

	for i=1, self:getSize() do
		if self.members[i].lifetime > self.lifetime then
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
			self:emitParticle(self.members[i])
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
	local i = 1
	while i <= self:getSize() do
		if not self.members[i].exists then
			break
		end
		i = i + 1
	end
	if i >= self:getSize() then
		--No available particles
		return
	end

	local launchParticle = self.members[i]
	
	launchParticle.lifetime = 0
	launchParticle.x = self.x
	launchParticle.y = self.y
	launchParticle.accelerationY = self.gravity
	launchParticle.dragX = self.drag
	launchParticle.dragY = self.drag
	launchParticle.exists = true
	launchParticle.alive = true
	launchParticle.visible = true

	local velocity = math.random(self.velocityMin, self.velocityMax)
	local angle = ((math.pi / 180 ) * math.random(self.emitAngle-self.angleRange,
							  self.emitAngle+self.angleRange)) % 360
	launchParticle.velocityX = velocity * math.cos(angle)
	launchParticle.velocityY = -velocity * math.sin(angle)
end

function Emitter:setPosition(X, Y)
	self.x = X or 0
	self.y = Y or 0
end
function Emitter:setAngle(Angle, Range)
	self.emitAngle = Angle
	self.angleRange = Range
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

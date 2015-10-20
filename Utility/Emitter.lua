--Class for a particle Emitter
Emitter = {
	x = 0,	--Initial X location of emitter
	y = 0,	--Initial Y location of emitter
	gravity = 0,	--Gravity applied to all particles (Y only)
	drag = 0,		--Drag applied to all particles (X and Y)
	emitAngle = 0,	--Base angle (radians) that particles are launched at
	angleRange = math.pi,	--Max angle deviation in either direction
	velocityMin = 0,		--Minimum launch velocity
	velocityMax = 100,		--Maximum launch velocity
	emitDelay = 0,		--Time delay between emissions (does not apply if launchAll==true)
	emitTimer = 0,		--Counter for counting delay between emissions
	emitCount = -1,		--Number of particles to launch in burst. Use -1 for all
	emitSound = nil,
	launchAll = true,	--Launch all particles at once, or sequentially
	enabled = false,	--Whether the emitter is on or off
	lifetime = 30,		--How long each particle lasts after emission
	parent = nil,		--(Optional) Parent object. See lockParent() for info
	parentOffsetX = 0,
	parentOffsetY = 0,
	autoEnable = false,	--Turn off/on with parent
	target = nil,		--(Optional) Target object. See lockTarget() for info
	targetOffsetX = 0,
	targetOffsetY = 0,
	callbackObject = nil,
	callbackFunction = nil
}

--[[Create a new Emitter at the given location
]]
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
	LaunchAll	Launch all the particles at once. If not, the Delay
				 argument is used to launch particles sequentially.
	Lifetime	How long each particle lasts in seconds (default 30s)
	Delay		Delay for sequential launch between particles
	Count		Number of particles to launch. Use -1 for all
]]
function Emitter:start(LaunchAll, Lifetime, Delay, Count)
	if LaunchAll == nil then
		--Default to launching all particles at once
		LaunchAll = true
	end
	self.launchAll = LaunchAll
	self.lifetime = Lifetime
	self.emitDelay = Delay
	self.emitCount = Count
	self.enabled = true
end
--[[ Restart the emitter.
	Enables the emitter and resets the timer.
]]
function Emitter:restart()
	self.enabled = true
	self.emitTimer = 0
end

--[[ Stop the emitter from launching more particles
]]
function Emitter:stop()
	self.enabled = false
end

--[[ Add a particle for the emitter to launch
	NewParticle Sprite object to be launched. Can be static or animated.
]]
function Emitter:addParticle(NewParticle)
	--Disable particle, and add to members
	NewParticle.health = 0
	NewParticle.exists = false
	self:add(NewParticle)
end

--[[ Update the emitter
]]
function Emitter:update()
	for i=1, self.length do
		--Check all particles
		local curParticle = self.members[i]
		if curParticle.lifetime > self.lifetime then
			--Destroy particle if past its lifetime
			curParticle.exists = false
		end
		if not curParticle:onScreen() then
			--Destroy particle if not on screen
			curParticle.exists = false
		end
	end
	
	--Update all particles
	Group.update(self)
	
	--Check enabled status
	if not self.enabled then
		if self.parent ~= nil and self.autoEnable then
			if self.parent.exists then
				--Restart if parent exists
				self:restart()
			end
		end
		--Not enabled, so don't emit
		return
	end
	
	--Emission
	if self.launchAll then
		--Emitter is set to launch all particles at once
		self.enabled = false
		
		for i=1, self.length, 1 do
			self:emitParticle()
		end
	else
		--Launch a single particle
		
		self.emitTimer = self.emitTimer - General.elapsed
		if self.emitTimer > 0 then
			return
		end
		
		--Launch a particle
		self:emitParticle()
		--Reset timer
		self.emitTimer = self.emitDelay
		--Decrement remaining count
		self.emitCount = self.emitCount - 1
		if self.emitCount == 0 then
			--Turn off once particles launched
			self.enabled = false
		end
	end
end

--[[ Emit a single particle. Will cancel if not particles available.
]]
function Emitter:emitParticle()
	if self.parent ~= nil then
		if not self.parent.exists and self.autoEnable then
			--Stop if the parent no longer exists
			self:stop()
			return
		end
		--Snap position to parent
		self.x = self.parent.x + self.parentOffsetX
		self.y = self.parent.y + self.parentOffsetY
	end
	if self.target ~= nil then
		--Set angle if there is a target
		self.emitAngle = math.atan2(self.y - (self.target.y + self.targetOffsetY),
									(self.target.x + self.targetOffsetX) - self.x)
	end

	--Find the first available particle
	local particle = self:getFirstAvailable(true)
	
	if particle == nil then
		--No particles available, so cancel
		return
	end
	
	--Reset particle values
	particle.lifetime = 0
	particle.x = self.x
	particle.y = self.y
	particle.accelerationY = self.gravity
	particle.dragX = self.drag
	particle.dragY = self.drag
	particle.exists = true
	particle.alive = true
	particle.visible = true
	
	if particle.animated then
		particle:restartAnimation()
	end

	--Calculate random velocity and angle
	local velocity = math.random(self.velocityMin, self.velocityMax)
	local angle = self.emitAngle + (2 * math.random()-1) * self.angleRange
	particle.velocityX = velocity * math.cos(angle)
	particle.velocityY = -velocity * math.sin(angle)
	
	--Play sound if specified
	if self.emitSound ~= nil then
		self.emitSound:rewind()
		self.emitSound:play()
	end
	--Run callback if specified
	if self.callbackFunction ~= nil then
		self.callbackFunction(self.callbackObject)
	end
end

--[[ Move the emitter to a location
	X	X position to move to
	Y	Y position to move to
]]
function Emitter:setPosition(X, Y)
	self.x = X
	self.y = Y
end
--[[ Set exact emitter launch angle
	Angle	Angle to launch (degrees)
	Range	Max degree deviation from Angle, in either direction
]]
function Emitter:setAngle(Angle, Range)
	self.emitAngle = Angle * (math.pi/180)
	if Range == nil then
		self.angleRange = 0
	else
		self.angleRange = (Range % 180) * (math.pi/180) or 0
	end
end
--[[ Set angle by specifying a target position
	TargetX		X position of target
	TargetY		Y position of target
	Range		Max degree deviation in either direction
]]
function Emitter:setTarget(TargetX, TargetY, Range)
	local dx = TargetX - self.x
	local dy = self.y - TargetY
	self.emitAngle = math.atan2(dy, dx)
	
	self.angleRange = Range or 0
end
--[[ Set launch speed of particles
	Min		Minimum speed of particle
	Max		(Optional) Give particles a range of speeds by specifying a maximum
]]
function Emitter:setSpeed(Min, Max)
	self.velocityMin = Min
	if Max == nil then
		--Use only Min value if no max specified
		Max = Min
	end
	self.velocityMax = Max
end
--[[ Set a vertical acceleration for all particles
]]
function Emitter:setGravity(Gravity)
	self.gravity = Gravity
end
--[[ Set a drag value for all particles (both X/Y)
]]
function Emitter:setParticleDrag()
	self.drag = Drag
end
--[[ Set the sound to play when a particle is emitted
]]
function Emitter:setSound(SoundPath)
	self.emitSound = love.audio.newSource(SoundPath)
end

function Emitter:setCallback(CallbackObject, CallbackFunction)
	self.callbackObject = CallbackObject
	self.callbackFunction = CallbackFunction
end

--[[ Lock a parent object for the emitter.  Emitter will sync
	its position to the parent object, with given offset.
	Parent	Object to lock as this emitter's parent
	AutoEnable	Turn on/off if the parent exists or not
	OffsetX	X offset relative to parent location to lock to (defaults to center)
	OffsetY Y offset relative ot parent location to lock to (defaults to center)
]]
function Emitter:lockParent(Parent, AutoEnable, OffsetX, OffsetY)
	self.parent = Parent
	self.autoEnable = AutoEnable
	self.parentOffsetX = OffsetX or Parent.width/2
	self.parentOffsetY = OffsetY or Parent.height/2
end

--[[ Lock an object as the emitter's target. All particles will be
	angled towards the Target, with specified angle range.
	Target	Object to lock emissions towards
	Range	Radian angle error range that particles emit within
	OffsetX X offset relative to target location to lock to (defaults to center)
	OffsetY Y offset relative to target location to lock to (defaults to center)
]]
function Emitter:lockTarget(Target, Range, OffsetX, OffsetY)
	self.target = Target
	self.angleRange = Range or 0
	self.targetOffsetX = OffsetX or Target.width/2
	self.targetOffsetY = OffsetY or Target.height/2
end

--[[ Add time to the emitter's timer. Does nothing if 
		LaunchAll is set to True
]]
function Emitter:addDelay(Time)
	self.emitTimer = self.emitTimer + Time
end

function Emitter:getType()
	return "Emitter"
end
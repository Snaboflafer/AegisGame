--Class for a particle Emitter
Emitter = {
	x = 0,	--Initial X location of emitter
	y = 0,	--Initial Y location of emitter
	width = 0,	--Horizontal area where particles can be emitted from (emitter position is centered, not top left)
	height = 0,	--Vertical area where particles can be emitted from
	velocityX = 0,	--Horizontal velocity of the emitter (not used)
	velocityY = 0,	--Vertical velocity of the emitter
	gravity = 0,	--Acceleration applied to all particles (Y only)
	dragX = 0,		--Drag applied to all particles (X)
	dragY = 0,		--Drag applied to all particles (Y)
	emitOffset = 0,	--Distance from emitter point that particles are launched from
	emitAngle = 0,	--Base angle (radians) that particles are launched at
	angleRange = math.pi,	--Max angle deviation in either direction
	velocityMin = 0,		--Minimum launch velocity
	velocityMax = 100,		--Maximum launch velocity
	emitDelay = 0,		--Time delay between emissions (does not apply if launchBurst==true)
	emitTimer = 0,		--Counter for counting delay between emissions
	emitCount = -1,		--Number of particles to launch in burst. Use -1 for all
	emitSound = nil,	--Sound to play when emitting a particle
	launchBurst = true,	--Launch all particles at once, or sequentially
	enabled = false,	--Whether the emitter is on or off
	lifetime = 30,		--How long each particle lasts after emission
	parent = nil,		--(Optional) Parent object. See lockParent() for info
	parentOffsetX = 0,	--Offset from parent's position
	parentOffsetY = 0,
	autoEnable = false,	--Turn off/on with parent
	target = nil,		--(Optional) Target object. See lockTarget() for info
	targetOffsetX = 0,	--Offset from target's position
	targetOffsetY = 0,
	callbackObject = nil,	--Callback (object) for when a particle is emitted
	callbackFunction = nil,
	activeStart = 1,	--Starting index of the active particle block
	numActive = 0		--Number of active particles
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
	s.velocityX = 0
	s.velocityY = 0
	
	s.emitDelay = 0
	s.emitTimer = 0
	s.emitCount = -1
	s.emitSound = nil
	s.launchBurst = true
	s.enabled = false
	
	
	return s
end

--[[ Start the emitter
	LaunchBurst	Launch a burst of particles at once. If not, the Delay
				 argument is used to launch single particles sequentially.
	Lifetime	How long each particle lasts in seconds (default 30s)
	Delay		Delay for sequential launch between particles
	Count		Number of particles to launch (in series, or burst). Use -1 for all
]]
function Emitter:start(LaunchBurst, Lifetime, Delay, Count)
	if LaunchBurst == nil then
		--Default to launching all particles at once
		LaunchBurst = true
	end
	self.launchBurst = LaunchBurst
	self.lifetime = Lifetime
	self.emitDelay = Delay
	self.emitCount = Count
	self.enabled = true
end
--[[ Restart the emitter, using previously set launch parameters.
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
	NewParticle.massless = true
	NewParticle.killOffScreen = true
	self:add(NewParticle)
end

--[[ Update the emitter
]]
function Emitter:update()
	local startIndex = self.activeStart
	local activeCount = self.numActive
	local length = self.length
	local index
	local curParticle
	for i=0, activeCount-1 do
		--Check active particle (begin from activeStart, loop around)
		index = (startIndex+i-1) % length +1	--Blame Lua to complicate a simple array loop. Why you do this, Lua?
		curParticle = self.members[index]
		if curParticle.lifetime > self.lifetime or not curParticle.exists then
			curParticle.exists = false
			activeCount = activeCount - 1
			--Increment start point
			self.activeStart = (startIndex+i) % length + 1
			--error("Out of time.\n" .. 
			--		"Active: " .. activeCount .. "\n" ..
			--		"Start:  " .. self.activeStart)
		else
			--curParticle:update()
			break
		end
	end
	self.numActive = activeCount
	
	--Update all particles
	--Will fix optimal method (below) later
	Group.update(self)

	--[[
	startIndex = self.activeStart
	
	for i=1, activeCount-1 do
		index = (startIndex+i-1) % length +1
		curParticle = self.members[index]
		if curParticle.exists then
			curParticle:update()
		else
			--Particle has been killed, need to move
			table.remove(self.members, index)
			activeCount = activeCount - 1
			table.insert(self.members, (startIndex+activeCount-1)%length + 1, curParticle)
		end
	end
	self.numActive = activeCount
	--]]
	
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
	
	--Set angle if there is a target
	if self.target ~= nil then
		self.emitAngle = math.atan2(self.y - (self.target.y + self.targetOffsetY),
									(self.target.x + self.targetOffsetX) - self.x)
	end
	
	--Emission
	self.emitTimer = self.emitTimer - General.elapsed
	if self.emitTimer > 0 then
		return
	end
	--Reset timer
	self.emitTimer = self.emitDelay

	if self.launchBurst then
		--Emitter is set to launch multiple particles at once
		self.enabled = false
		
		local launchCount
		if self.emitCount > 0 then
			launchCount = self.emitCount
		else
			launchCount = self.length
		end
		for i=1, launchCount do
			self:emitParticle()
		end
	else
		--Launch a single particle
		self:emitParticle()
		--Decrement remaining count
		self.emitCount = self.emitCount - 1
		if self.emitCount == 0 then
			--Turn off once particles launched
			self.enabled = false
		end
	end
end

--[[ Emit a single particle. Will cancel if no particles available.
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
		--self.velocityX = self.parent.velocityX
		--self.velocityY = self.parent.velocityY
	end

	--Find the first available particle
	--local particle = self:getFirstAvailable(true)
	local particle = self.members[(self.activeStart+self.numActive-1) % self.length + 1]
	
	if particle.exists then
		--Particle found already exists, so don't use it
		return
	end
	
	self.numActive = self.numActive + 1
	
	--Calculate random velocity and angle
	local velocity = math.random(self.velocityMin, self.velocityMax)
	local angle = self.emitAngle + (2 * math.random()-1) * self.angleRange
	--Set particle velocity, using calculated value and emitter movement
	particle.velocityX = velocity * math.cos(angle) + self.velocityX
	particle.velocityY = -velocity * math.sin(angle) + self.velocityY

	--Reset particle values
	particle.lifetime = 0
	particle.x = self.x + .5*self.width*(math.random()-.5)  + self.emitOffset * math.cos(angle)
	particle.y = self.y + .5*self.height*(math.random()-.5) + self.emitOffset * math.sin(angle)
	particle.accelerationY = self.gravity
	particle.accelerationX = 0
	particle.dragX = self.dragX
	particle.dragY = self.dragY
	particle.exists = true
	particle.alive = true
	--particle.visible = true
	
	--Handle animation
	if particle.animated then
		particle:restartAnimation()
	end

	
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

function Emitter:setSize(Width, Height)
	self.width = Width or 0
	self.height = Height or 0
end
function Emitter:setOffset(Offset)
	self.emitOffset = Offset or 0
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
function Emitter:setDrag(DragX, DragY)
	DragX = DragX or 0
	
	self.dragX = DragX
	self.dragY = DragY or DragX
end
--[[ Set the sound to play when a particle is emitted
]]
function Emitter:setSound(SoundPath)
	self.emitSound = love.audio.newSource(SoundPath)
end

--[[ Set a callback function for whenever a particle is emitted
	CallbackObject	Target object of callback
	CallbackFunction	Function to call
]]
function Emitter:setCallback(CallbackObject, CallbackFunction)
	self.callbackObject = CallbackObject
	self.callbackFunction = CallbackFunction
end

function Emitter:getAngle()
	return self.emitAngle
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
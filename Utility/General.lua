--General class for game data
General = {
	elapsed = 0,
	volume = 1,
	timeScale = 1,
	showBounds = false,
	screenW = 0,
	screenH = 0,
	activeState = nil,
	loadedStates = nil,
	worldX = 0,
	worldY = 0,
	worldWidth = 0,
	worldHeight = 0,
	colDivisionsX = 16,
	colDivisionsY = 16,
	camera = nil,
	score = 0,
	curLevel = 1,
}

function General:setCurrentLevel(Level)
	General.curLevel = Level
end

function General:getCurrentLevel()
	return General.curLevel
end

function General:setScore(Value)
	General.score = Value
end

function General:getScore()
	return General.score
end

function General:init()
	s = {}
	
	setmetatable(s, self)
	self.__index = self
	self.headerFont = love.graphics.newFont("fonts/Square.ttf", 96)
	self.subFont = love.graphics.newFont("fonts/lucon.ttf", 32)
	self.elapsed = 0
	self.camera = Camera:new(0,0)
	self.volume = 1
	self.timeScale = 1
	self.screenW = love.window.getWidth()
	self.screenH = love.window.getHeight()
	self.activeState = nil
	self.loadedStates = nil
	
	return s
end

function General:draw()
	if self.loadedStates == nil then
		return
	end
	for i=1, self.loadedStates:getSize(), 1 do
		if self.loadedStates.members[i].camera ~= nil then
			self.camera = self.loadedStates.members[i].camera
		end
		State.draw(self.loadedStates.members[i])
	end
end

function General:getVolume()
	return self.volume
end

function General:incrementVolume() 
	if self.volume < 9 then
		self.volume = self.volume + 1
	end
end

function General:decrementVolume()
	if self.volume > 0 then
		self.volume = self.volume - 1
	end
end

function General:getFPS()
	return 1/General.elapsed
end

function General:newCamera(X, Y)
	if (self.camera ~= nil) then
		--self.camera:destroy()
	end
	
	self.camera = Camera:new(X, Y)
	return self.camera
end
function General:getCamera()
	return self.camera
end
function General:setWorldBounds(X,Y,Width,Height)
	worldX = X
	worldY = Y
	worldWidth = Width
	worldHeight = Height
end

--[[ Collide between two objects or group
	Object1		First Sprite or Group object to collide
	Object2		Second Sprite or Group object to collide
	CallbackTarget	(Optional) Target object of callback function
	CallbackFunction	(Optional) Function to call during collision
	PreCollide	(Optional) Do callback before basic collision
				 resolution occurs, instead of after
]]
function General:collide(Object1, Object2, CallbackTarget, CallbackFunction, PreCollide)
	if Object1 == nil or not Object1.solid or not Object1.exists then
		return
	end
	
	local callbackTarget = CallbackTarget
	local callbackFunction = CallbackFunction
	if PreCollide == nil then
		PreCollide = false
	end
	
	
	--Handle groups and unresolvable collisions
	if Object1 == Object2 or Object2 == nil then
		--Cannot collide a single sprite against itself
		return
	elseif not Object1.solid or not Object2.solid or not Object1.exists or not Object2.exists then
		--Can't collide against one object
		return false
	elseif Object1.members ~= nil then
		--First object is a group
		
		local didCollide = false
		local result
		if Object1 == Object2 or Object2 == nil then
			--Collide within group
			for k1,v1 in pairs(Object1.members) do
				for k2,v2 in pairs(Object1.members) do
					result = General:collide(Object1.members[k1], Object1.members[k2], CallbackTarget, CallbackFunction, PreCollide)
					didCollide = didCollide or result
				end
			end
		else
			--Collide each member of Group1 with Object2
			if not Object2.solid or not Object2.exists then
				--Cancel if Object2 cannot be collided against
				return
			end
			for i=1, Object1.length do
				result = General:collide(Object1.members[i], Object2, CallbackTarget, CallbackFunction, PreCollide)
				didCollide = didCollide or result
			end
			--for k,v in pairs(Object1.members) do
			--	didCollide = didCollide or General:collide(v, Object2, CallbackTarget, CallbackFunction, PreCollide)
			--end
		end
		return didCollide
	elseif Object2.members ~= nil then
		local didCollide = false
		local result
		for i=1, Object2.length do
			result = General:collide(Object1, Object2.members[i], CallbackTarget, CallbackFunction, PreCollide)
			didCollide = didCollide or result
		end
		return didCollide
	end
	
	
	local obj1X = Object1.x
	local obj1Y = Object1.y
	local obj1W = Object1.width
	local obj1H = Object1.height
	local obj2X = Object2.x
	local obj2Y = Object2.y
	local obj2W = Object2.width
	local obj2H = Object2.height
	
	if obj2X > obj1X + obj1W or
		obj1X > obj2X + obj2W or
		obj2Y > obj1Y + obj1H or
		obj1Y > obj2Y + obj2H then
		
		--No collisions
		return false
	end
	
	--Collision occured, resolve:
	
	if PreCollide == true and callbackFunction ~= nil then
		callbackFunction(callbackTarget, Object1, Object2)
	end
	
	--Handle immovable and massless objects
	local obj1IM = Object1.immovable
	local obj2IM = Object2.immovable
	if Object1.massless and not Object2.massless then
		obj2IM = true
	end
	if Object2.massless and not Object1.massless then
		obj1IM = true
	end
	
	--Determine distance and overlap amount
	local dx = (obj2X + obj2W/2) - (obj1X + obj1W/2)
	local dy = (obj2Y + obj2H/2) - (obj1Y + obj1H/2)
	local overlapX = math.abs(dx) - .5*(obj2W + obj1W)
	local overlapY = math.abs(dy) - .5*(obj1H + obj2H)
	
	
	local obj1VX = Object1.velocityX
	local obj1VY = Object1.velocityY
	local obj2VX = Object2.velocityX
	local obj2VY = Object2.velocityY
	
	--Collide in direction of least penetration
	if math.abs(overlapX) < math.abs(overlapY) then
		--Collide horizontal
		if dx > 0 then
			if not obj1IM then Object1.x = Object2:getLeft() - obj1W end
			if not obj2IM then Object2.x = Object1:getRight() end
			Object1.touching = Sprite.RIGHT
			Object2.touching = Sprite.LEFT
		else
			if not obj1IM then Object1.x = Object2:getRight() end
			if not obj2IM then Object2.x = Object1:getLeft() - obj2W end
			Object1.touching = Sprite.LEFT
			Object2.touching = Sprite.RIGHT
		end
		if not obj1IM then
			obj1VX = -obj1VX * Object1.bounceFactor
			obj1VY = obj1VY*(1-Object1.friction) + obj2VY*Object1.friction
		end
		if not obj2IM then
			obj2VX = -obj2VX * Object2.bounceFactor
			obj2VY = obj2VY*(1-Object2.friction) + obj1VY*Object2.friction
		end
	else
		--Collide vertical
		if dy > 0 then
			if not obj1IM then Object1.y = Object2:getTop() - obj1H end
			if not obj2IM then Object2.y = Object1:getBottom() end
			Object1.touching = Sprite.DOWN
			Object2.touching = Sprite.UP
		else
			if not obj1IM then Object1.y = Object2:getBottom() end
			if not obj2IM then Object2.y = Object1:getTop() - obj2H end
			Object1.touching = Sprite.UP
			Object2.touching = Sprite.DOWN
		end
		if not obj1IM then
			obj1VY = -obj1VY * Object1.bounceFactor
			obj1VX = obj1VX*(1-Object1.friction) + obj2VX*Object1.friction
		end
		if not obj2IM then
			obj2VY = -obj2VY * Object2.bounceFactor
			obj2VX = obj2VX*(1-Object2.friction) + obj1VX*Object2.friction
		end
	end
	
	Object1.velocityX = obj1VX
	Object2.velocityX = obj2VX
	Object1.velocityY = obj1VY
	Object2.velocityY = obj2VY
	
	if not PreCollide and callbackFunction ~= nil then
		callbackFunction(callbackTarget, Object1, Object2)
	end
	
	Object1:collide(Object2)
	Object2:collide(Object1)
	
	return true
	
end

function General:setState(NewState, CloseOld)
	if CloseOld == nil then
		CloseOld = true
	end
	if CloseOld and self.loadedStates ~= nil then
		--for i=1, self.loadedStates:getSize() do
		--	General:closeState(self.loadedStates.members[i], true)
		--end
		if self.activeState ~= nil then
			--There is a current state to close
			General:closeState(self.activeState, true)
		end
	end
	
	self.activeState = NewState
	if not self.activeState.loaded then
		--Load if not yet loaded
		self.activeState:load()
		
		--Create loaded group if needed
		if self.loadedStates == nil then
			self.loadedStates = Group:new()
		end
		--Add new state
		self.loadedStates:add(NewState)
	end
	--Start new state
	self.activeState:start()
end

function General:closeState(OldState, Force)
	if Force == nil then
		Force = true
	end

	if OldState == self.activeState and not Force then
		--Can't close the active state. Use setState instead!
		return
	end
	if not OldState.loaded then
		--Can't close an unloaded state
		return
	end
	
	--Unload and remove from loaded group
	OldState:unload()
	if self.loadedStates ~= nil then
		self.loadedStates:delete(OldState)
		--Delete loaded group if empty
		if self.loadedStates:getSize() == 0 then
			self.loadedStates = nil
		end
	end
end

return General

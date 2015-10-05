--General class for game data
General = {
	elapsed = 0,
	volume = 1,
	timeScale = 1,
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
	camera = nil
}

function General:init()
	s = {}
	
	setmetatable(s, self)
	self.__index = self
	self.headerFont = love.graphics.newFont("fonts/Square.ttf", 96)
	self.subFont = love.graphics.newFont("fonts/04b09.ttf", 32)
	self.elapsed = 0
	self.camera = Camera:new(X,Y)
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
		State.draw(self.loadedStates.members[i])
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

function General:collide(Object1, Object2)
	if not Object1.solid or not Object1.exists then
		return
	end
	
	if Object1:getType() == "Group" then
		--First object is a group
		
		local didCollide = false
		if Object1 == Object2 or Object2 == nil then
			--Collide within group
			for k1,v1 in pairs(Object1.members) do
				for k2,v2 in pairs(Object1.members) do
					didCollide = didCollide or General:collide(Object1.members[k1], Object1.members[k2])
				end
			end
		else
			--Collide each member of Group1 with Object2
			if not Object2.solid or not Object2.exists then
				--Cancel if Object2 cannot be collided against
				return
			end
			for k,v in pairs(Object1.members) do
				didCollide = didCollide or General:collide(v, Object2)
			end
		end
		return didCollide
	elseif Object1 == Object2 or Object2 == nil then
		--Cannot collide a single sprite against itself
		return
	elseif not Object2.solid or not Object2.exists then
		--Cannot collide against Object2
		return
	end
	
	if Object2:getType() == "Group" then
		local didCollide = false
		for k,v in pairs(Object2.members) do
			didCollide = didCollide or General:collide(Object1, Object2.members[k])
		end
		return didCollide
	end
	
	
	if Object1 == Object2 or not Object1.solid or not Object2.solid then
		return false
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
	
	--Collide in direction of least penetration
	if math.abs(overlapX) < math.abs(overlapY) then
		--Collide horizontal
		if dx > 0 then
			if not obj1IM then Object1.x = Object2:getLeft() - obj1W end
			if not obj2IM then Object2.x = Object1:getRight() end
		else
			if not obj1IM then Object1.x = Object2:getRight() end
			if not obj2IM then Object2.x = Object1:getLeft() - obj2W end
		end
		Object1.velocityX = -Object1.velocityX * Object1.bounceFactor
		Object2.velocityX = -Object2.velocityX * Object2.bounceFactor
	else
		--Collide vertical
		if dy > 0 then
			if not obj1IM then Object1.y = Object2:getTop() - obj1H end
			if not obj2IM then Object2.y = Object1:getBottom() end
		else
			if not obj1IM then Object1.y = Object2:getBottom() end
			if not obj2IM then Object2.y = Object1:getTop() - obj2H end
		end
		Object1.velocityY = -Object1.velocityY * Object1.bounceFactor
		Object2.velocityY = -Object2.velocityY * Object2.bounceFactor
	end

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

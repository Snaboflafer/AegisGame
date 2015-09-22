--General class for game data
General = {
	elapsed = 0,
	camera = {x=0, y=0},
	volume = 1,
	timeScale = 1,
	screenW = 0,
	screenH = 0,
	activeState = nil,
	worldX = 0,
	worldY = 0,
	worldWidth = 0,
	worldHeight = 0,
	colDivisionsX = 16,
	colDivisionsY = 16
}

function General:init()
	s = {}
	
	setmetatable(s, self)
	self.__index = self
	
	self.elapsed = 0
	self.camera = {}
	self.volume = 1
	self.timeScale = 1
	self.screenW = love.window.getWidth()
	self.screenH = love.window.getHeight()
	self.activeState = nil
	
	return s
end

function General:getFPS()
	return 1/General.elapsed
end

function General:newCamera(X, Y)
	if (self.camera ~= nil) then
		--self.camera:destroy()
	end
	
	self.camera = {}
	self.camera = {
		x = 0,
		y = 0
	}
end
function General:setWorldBounds(X,Y,Width,Height)
	worldX = X
	worldY = Y
	worldWidth = Width
	worldHeight = Height
end

function General:collide(Object1, Object2)

	if Object1:getType() == "Group" then
		if Object1 == Object2 or Object2 = nil then
			--Collide within group
			for k1,v1 in pairs(Object1.members) do
				for k2,v2 in pairs(Object1.members) do
					General:collide(Object1.members[k1], Object1.members[k2])
				end
			end
		else
			for k,v in pairs(Object1.members) do
				General:collide(v, Object2)
			end
		end
		return
	end
	if Object2:getType() == "Group" then
		for k,v in pairs(Object2.members) do
			General:collide(Object1, Object2.members[k])
		end
		return
	end
	
	if Object1 == Object2 then
		return
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
		return
	end

	local obj1MidX = obj1X + obj1W/2
	local obj1MidY = obj1Y + obj1H/2
	local obj2MidX = obj2X + obj2W/2
	local obj2MidY = obj2Y + obj2H/2
	
	local dx = (obj2MidX - obj1MidX)
	local dy = (obj2MidY - obj1MidY)
	
	local absDx = math.abs(dx)
	local absDy = math.abs(dy)
	
	local VELOCITY_THRESHOLD = 1
	
	if math.abs(absDx - absDy) < .1 then
		--Less than threshold, so from a corner
		
		if dx < 0 then
			Object1.x = Object2:getRight()
		else
			Object1.x = Object2:getLeft() - obj1W
		end
		
		if dy < 0 then
			Object1.y = Object2:getBottom()
		else
			Object1.y = Object2:getTop() - obj1H
		end
		
		--Randomize reflection direction
		if math.random() < .5 then
			Object1.velocityX = -Object1.velocityX * Object1.bounceFactor
			
			if math.abs(Object1.velocityX) < VELOCITY_THRESHOLD then
				Object1.velocityX = 0
			end
		else
			Object1.velocityY = -Object1.velocityY * Object1.bounceFactor
			
			if math.abs(Object1.velocityY) < VELOCITY_THRESHOLD then
				Object1.velocityY = 0
			end
		end
		
	elseif absDx > absDy then
		--Approaching from side
		if dx < 0 then
			Object1.x = Object2:getRight()
		else
			Object1.x = Object2:getLeft() - obj1W
		end
		
		Object1.velocityX = -Object1.velocityX * Object1.bounceFactor
		
		if math.abs(Object1.velocityX) < VELOCITY_THRESHOLD then
			Object1.velocityX = 0
		end
	else
		if dy < 0 then
			Object1.y = Object2:getBottom()
		else
			Object1.y = Object2:getTop() - obj1H
		end
		
		Object1.velocityY = - Object1.velocityY * Object1.bounceFactor
		if math.abs(Object1.velocityY) < VELOCITY_THRESHOLD then
			Object1.velocityY = 0
		end
	end
end

function General:setState(NewState, CloseOld)
	if CloseOld == nil then
		CloseOld = true
	end
	if CloseOld then
		if self.activeState ~= nil then
			self.activeState:unload()
		end
	end
	
	self.activeState = NewState
	if not self.activeState.loaded then
		self.activeState:load()
	end
	self.activeState:start()
end

return General

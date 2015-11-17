PlayerShip = {
	activeMode = "ship",
	SHIELDCHARGERATE = .3
}

function PlayerShip:new(X,Y,ImageFile)
	s = Player:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Player)
	self.__index = self
	s.magnitude = 400
	s.momentArm = math.sqrt(s.magnitude^2/2)
    s.change = love.audio.newSource(LevelManager:getSound("ship_to_mech"))
	return s
end

function PlayerShip:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
	self:addAnimation("down_in", {2, 3, 4, 5}, .07, false)
	self:addAnimation("down_out", {6, 7, 8, 9}, .07, false)
	self:addAnimation("up_in", {12, 13, 14, 15}, .07, false)
	self:addAnimation("up_out", {16, 17, 18, 19}, .07, false)
	self:playAnimation("idle")
end

-- as of now you must use this method to change the magnitude
-- otherwise, the momentArm will not be recalculated
function PlayerShip:changeMagnitude(m)
	self.magnitude = m
	self.momentArm = math.sqrt(self.magnitude^2/2)
end

function PlayerShip:update()
    
	if Player.enableControls then
		if love.keyboard.isDown('w') and love.keyboard.isDown('d') then
			self.velocityX = self.momentArm
			self.velocityY = -self.momentArm
		elseif love.keyboard.isDown('d') and love.keyboard.isDown('s') then
			self.velocityX = self.momentArm
			self.velocityY = self.momentArm
		elseif love.keyboard.isDown('s') and love.keyboard.isDown('a') then
			self.velocityX = -self.momentArm
			self.velocityY = self.momentArm
		elseif love.keyboard.isDown('a') and love.keyboard.isDown('w') then
			self.velocityX = -self.momentArm
			self.velocityY = -self.momentArm
		elseif love.keyboard.isDown('w') then
			self.velocityX = 0
			self.velocityY = -self.magnitude
		elseif love.keyboard.isDown('s') then
			self.velocityX = 0
			self.velocityY = self.magnitude
		elseif love.keyboard.isDown('a') then
			self.velocityX = -self.magnitude
			self.velocityY = 0
		elseif love.keyboard.isDown('d') then
			self.velocityX = self.magnitude
			self.velocityY = 0
		else
			self.velocityX = 0
			self.velocityY = 0
		end
		--Keep up with screen scrolling
		self.velocityX = self.velocityX + GameState.cameraFocus.velocityX
	else
		self.velocityX = 0 + GameState.cameraFocus.velocityX
		self.velocityY = 0
	
	end
	
	--Determine animation to play
	if self.velocityY > 0 then
		--Going down
		if self.curAnim.name == "up_in" then
			self:playAnimation("up_out", false, true)
		else
			self:playAnimation("down_in")
		end
	elseif self.velocityY < 0 then
		--Going up
		if self.curAnim.name == "down_in" then
			self:playAnimation("down_out", false, true)
		else
			self:playAnimation("up_in")
		end
	else
		--Constant height
		if self.curAnim.name == "down_in" then
			self:playAnimation("down_out", false, true)
		end
		if self.curAnim.name == "up_in" then
			self:playAnimation("up_out", false, true)
		end
		self:playAnimation("idle")
	end
	
	--Recharge shield
	local shield = self.shield
	if shield < self.maxShield then
		shield = shield + General.elapsed * self.SHIELDCHARGERATE
		if shield > self.maxShield then
			shield = self.maxShield
		end
		self.shield = shield
		self:updateShield()
	end

	Player.update(self)
end

--[[ Enter ship mode
	X	X position
	Y	Y position
	VX	X velocity
	VY	Y velocity
	HP	Health
	SP	Shields
]]
function PlayerShip:enterMode(X, Y, VX, VY, HP, SP)
	self.change:rewind()
	self.change:play()
	self.x = X
	self.y = Y
	self.velocityX = VX
	self.velocityY = VY
	self.health = HP
	self.shield = SP
	self.exists = true
	if GameState.shieldOverlay ~= nil and GameState.shieldBar ~= nil then
		GameState.shieldOverlay:setColor({127,127,127})
		GameState.shieldBar:setAlpha(127)
	end
end

--[[ Exit ship mode. Returns required arguments for enterMode()
]]
function PlayerShip:exitMode()
	self.weapons[self.activeWeapon]:stop()
	self.exists = false
	return self.x, self.y, self.velocityX, self.velocityY, self.health, self.shield
end

function PlayerShip:destroy()
	Sprite.destroy(self)
end
function PlayerShip:attackStart()
	self.weapons[self.activeWeapon]:restart()
end

function PlayerShip:attackStop()

	self.weapons[self.activeWeapon]:stop()
end

function PlayerShip:collideGround()
	--Currently empty, required for Player
end

function PlayerShip:getType()
	return "PlayerShip"
end

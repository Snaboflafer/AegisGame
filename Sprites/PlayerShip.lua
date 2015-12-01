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

function PlayerShip:doConfig()
	Player.doConfig(self)
	
	local image, height, width = LevelManager:getPlayerShip()
	self:loadSpriteSheet(image, height, width)
	self:setAnimations()
	self:setCollisionBox(46, 34, 91, 20)
	self:lockToScreen(Sprite.ALL)
	--self.showDebug = true
	
	--standard
	local gunLocations = {{self.width/2+32,10},{self.width/2, 20}}
	for i=1, table.getn(gunLocations)do
		local playerGun = Emitter:new(0,0)

		for i=1, 10 do
			local curParticle = Sprite:new(0,0,LevelManager:getParticle("laser"))
			curParticle.attackPower = .35
			playerGun:addParticle(curParticle)
			GameState.playerBullets:add(curParticle)
		end
		playerGun:setSpeed(1000)
		playerGun:setAngle(0,0)
		playerGun:lockParent(self, false, gunLocations[i][1], gunLocations[i][2])
		playerGun:setSound(LevelManager:getSound("laser"))
		playerGun:start(false, 1, .12, -1)
		playerGun:stop()
		GameState.emitters:add(playerGun)
		self:addWeapon(playerGun, 1)
		--WEAPON 1 DPS: 2.5
	end

	--power
	for i=1, table.getn(gunLocations)do
		local playerGun = Emitter:new(0,0)

		for i=1, 10 do
			local curParticle = Sprite:new(0,0,LevelManager:getParticle("laser"))
			curParticle:setColor({255, 99, 71})
			curParticle.attackPower = .5
			playerGun:addParticle(curParticle)
			GameState.playerBullets:add(curParticle)
		end
		playerGun:setSpeed(1000)
		playerGun:setAngle(0,0)
		playerGun:lockParent(self, false, gunLocations[i][1], gunLocations[i][2])
		playerGun:setSound(LevelManager:getSound("laser"))
		playerGun:start(false, 1, .12, -1)
		playerGun:stop()
		GameState.emitters:add(playerGun)
		self:addWeapon(playerGun, 2)
		--WEAPON 1 DPS: 2.5
	end

	--spread
	local gunLocations = {{self.width/2+32,10},{self.width/2, 20}}
	for i=1, table.getn(gunLocations)do
		local playerGun = Emitter:new(0,0)

		for i=1, 10 do
			local curParticle = Sprite:new(0,0,LevelManager:getParticle("laser"))
			curParticle:setColor({30, 144, 255})
			curParticle.attackPower = .35
			playerGun:addParticle(curParticle)
			GameState.playerBullets:add(curParticle)
		end
		playerGun:setSpeed(1000)
		playerGun:setAngle(0,0)
		playerGun:lockParent(self, false, gunLocations[i][1], gunLocations[i][2])
		playerGun:setSound(LevelManager:getSound("laser"))
		playerGun:start(false, 1, .12, -1)
		playerGun:stop()
		GameState.emitters:add(playerGun)
		self:addWeapon(playerGun, 3)
		--WEAPON 1 DPS: 2.5
	end

	for j=1, 2 do
		playerGun = Emitter:new(0,0)
		for i=1, 7 do
			local curParticle = Projectile:new(0,0)
			curParticle:setColor({30, 200, 255})
			curParticle:loadSpriteSheet(LevelManager:getParticle("bullet-orange"), 20, 20)
			curParticle:setCollisionBox(4,4,14,14)
			curParticle:addAnimation("default", {1}, 0, false)
			curParticle:addAnimation("kill", {2,3,4,5}, .02, false)
			curParticle:playAnimation("default")
			curParticle.attackPower = .35
			playerGun:addParticle(curParticle)
			GameState.playerBullets:add(curParticle)
			GameState.worldParticles:add(curParticle)
		end
		playerGun:setSpeed(600,625)
		playerGun:setAngle(30 - 20 * j,1)
		playerGun:lockParent(self, false, gunLocations[j][1], gunLocations[j][2])
		playerGun:start(false, 2, .28, -1)
		playerGun:stop()
		GameState.emitters:add(playerGun)
		self:addWeapon(playerGun, 3)
	end

	local jetLocations = {{-22, -16},{-26, 25}}
	for i=1, table.getn(jetLocations) do
		local jetTrail = Emitter:new(0, 0)
		for j=1, 20 do
			local curParticle = Sprite:new(0, 0)
			curParticle:loadSpriteSheet(LevelManager:getParticle("trail"), 8,3)
			curParticle:addAnimation("idle", {1,2,3,4}, .08, false)
			curParticle:playAnimation("idle")
			jetTrail:addParticle(curParticle)
		end
		jetTrail:setSpeed(70, 150)
		jetTrail:setAngle(180)
		jetTrail:lockParent(self, true, jetLocations[i][1], jetLocations[i][2])
		jetTrail:start(false, .3, 0)
		GameState.emitters:add(jetTrail)
	end

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
			self:flash({0,174,239}, .2)
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
	self:stopWeapon()
	self.exists = false
	return self.x, self.y, self.velocityX, self.velocityY, self.health, self.shield
end

function PlayerShip:destroy()
	Sprite.destroy(self)
end
function PlayerShip:attackStart()
	self:restartWeapon()
end

function PlayerShip:attackStop()
	self:stopWeapon()
end

function PlayerShip:collideGround()
	--Currently empty, required for Player
end

function PlayerShip:getType()
	return "PlayerShip"
end

PlayerMech = {
	enableControls = true,
	activeMode = "mech",
	JUMPPOWER = 600,
	GRAVITY = 1400,
	DRAG = 200,
	fuel = 3,
	maxFuel = 3,
	jetThrust = -100
}

function PlayerMech:new(X,Y,ImageFile)
	s = Player:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Player)
	self.__index = self
	
	s.dragX = self.DRAG
	s.accelerationY = self.GRAVITY
	
	s.change = love.audio.newSource(LevelManager:getSound("mech_to_ship"))
	s.hitGround = love.audio.newSource(LevelManager:getSound("hit_ground"))
	return s
end

function PlayerMech:setAnimations()
	self:addAnimation("idle", {1}, .5, false)
	self:addAnimation("walk_f", {2,3,4,7,8,9,10,1}, .15, true)
	self:addAnimation("walk_b", {10,9,8,7,4,3,2,1}, .25, true)
	self:addAnimation("attack_f", {11,12,13,14,15}, .1, true)
	self:playAnimation("idle")
end

--[[ Assign Jet and Smoke emitters for the thruster
]]
function PlayerMech:assignThruster(Jet, Smoke)
	self.thrust_jet = Jet
	self.thrust_smoke = Smoke
end

local hittingGround = false
function PlayerMech:update()

	if self.enableControls then
		local pressedUp = love.keyboard.isDown("w")
		local pressedDown = love.keyboard.isDown("s")
		local pressedLeft = love.keyboard.isDown("a")
		local pressedRight = love.keyboard.isDown("d")
		local pressedJump = love.keyboard.isDown("k")
	
	
		--self.weapons[self.activeWeapon]:setPosition(self.x+66, self.y+12)
		if pressedRight then
			self.accelerationX = 800
			self.maxVelocityX = 200
		elseif pressedLeft then
			self.accelerationX = -550
			self.maxVelocityX = 120
		else
			self.accelerationX = 0
		end
		
		if self.touching == Sprite.DOWN then
			--On ground
			self.accelerationY = self.GRAVITY
			
			self.dragX = self.DRAG
			if pressedJump then
				self.velocityY = -self.JUMPPOWER
			end
			
			if self.fuel < self.maxFuel then
				self.fuel = self.fuel + General.elapsed * 10
				if self.fuel > self.maxFuel then
					self.fuel = self.maxFuel
				end
			end
		else
			--In air
			self.dragX = self.DRAG / 10
			
			local accY = self.accelerationY
			if pressedJump and self.velocityY>-50 and self.fuel > 0 then
				--Enable boost
				self.thrust_smoke:restart()
				
				local maxThrust = self.jetThrust
				if accY	> maxThrust then
					accY = accY - General.elapsed*12*(accY - maxThrust)
				end
				self.accelerationY = accY
				self.fuel = self.fuel - General.elapsed
				self.maxVelocityY = 45
			else
				self.thrust_smoke:stop()
				local gravity = self.GRAVITY
				if accY < gravity then
					accY = accY + General.elapsed * 2 * (gravity - accY)
					if accY > gravity then
						accY = gravity
					end
					self.accelerationY = accY
				end
				
				self.maxVelocityY = 1000
			end
		end
		

		if pressedUp then
			self.weapons[self.activeWeapon]:setAngle(20, 1)
			self.weapons[self.activeWeapon]:lockParent(self, false, 87, -24)
		elseif pressedDown then
			self.weapons[self.activeWeapon]:setAngle(-20, 1)
			self.weapons[self.activeWeapon]:lockParent(self, false, 127, 56)
		else
			self.weapons[self.activeWeapon]:setAngle(0,1)
			self.weapons[self.activeWeapon]:lockParent(self, false, 107, 16)
		end

	end
	
	if self.velocityX > 0 then
		self:playAnimation("walk_f")
	elseif self.velocityX < 0 then
		self:playAnimation("walk_b")
	else
		self:playAnimation("idle")
	end
	
	Player.update(self)
end

--[[ Enter mech mode
	X	X position
	Y	Y position
	VX	X velocity
	VY	Y velocity
	HP	Health
	SP	Shields
]]
function PlayerMech:enterMode(X, Y, VX, VY, HP, SP)
	self.change:rewind()
	self.change:play()
	self.x = X - self.width/2
	self.y = Y - self.height/2
	self.velocityX = VX
	self.velocityY = VY
	self.health = HP
	self.shield = SP
	self.exists = true
	
	if GameState.shieldOverlay ~= nil and GameState.shieldBar ~= nil then
		GameState.shieldOverlay:setColor({255,255,255})
		GameState.shieldBar:setAlpha(255)
	end
end

--[[ Exit mech mode. Returns required arguments for enterMode()
]]
function PlayerMech:exitMode()
	self.weapons[self.activeWeapon]:stop()
	self.thrust_smoke:stop()
	self.exists = false
	return self.x+self.width/2, self.y+self.height/2, self.velocityX, self.velocityY, self.health, self.shield
end

function PlayerMech:attackStart()
	self.weapons[self.activeWeapon]:restart()
end
function PlayerMech:attackStop()
	self.weapons[self.activeWeapon]:stop()
	self:playAnimation("idle")
end

function PlayerMech:fireGun()
	self:playAnimation("attack_f", true, true)
end

function PlayerMech:collideGround()
	if self.velocityY > 100 then
		General.activeState.camera:screenShake(.01,.05)
		self.hitGround:rewind()
		self.hitGround:play()
	end
end

function PlayerMech:getType()
	return "PlayerMech"
end

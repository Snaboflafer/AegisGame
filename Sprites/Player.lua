Player = {
	weapons = {},
	activeWeapon = 1,
	score = 0,
	enableControls = true,
	lockTransform = false,
	transformDelay = 1,
	invuln = false,
	shield = 0,
	maxShield = 0
}

thump = love.audio.newSource("sounds/thump.mp3")

function Player:new(X,Y,ImageFile)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.weapons = {}
	s.health = 3
	s.maxHealth = 3
	s.shield = 3
	s.maxShield = 3
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("player_hurt"))

	return s
end

function Player:addWeapon(GunEmitter, Slot)
	--if self.weapons == nil then
	--	self.weapons = Group:new()
	--end
	--self.weapons:add(GunEmitter)
	self.weapons[Slot] = GunEmitter
end

--Kill the player
function Player:kill()
	self.alive = false
	self.enableControls = false
	self:disableTransform()
	self.accelerationY = self.accelerationY + 200
	Timer:new(2, GameState, GameState.gameOver)
end

function Player:updateScore(S)
	self.score = self.score + S
end

function Player:getScore()
	return self.score
end

function Player:update()
	Sprite.update(self)
	
	local modeMaskWidth = GameState.modeMask.scaleX
	if self.lockTransform then
		modeMaskWidth = modeMaskWidth - (General.elapsed/self.transformDelay)
		if modeMaskWidth < 0 then
			modeMaskWidth = 0
		end
		GameState.modeMask.scaleX = modeMaskWidth
	end
end

--[[ Hurt the player by the specified amount
	Damage	Amount of health or shields to detract
]]
function Player:hurt(Damage)
	if self.invuln then
		return
	end
	if self.activeMode == "mech" and self.shield > 0 then
		--Try rerouting damage to shields if in mech mode
		Sprite.hurt(self, Damage, "shield")
		self:updateShield()
	else
		Sprite.hurt(self, Damage)
		self:updateHealth()
	end
	
	self.sfxHurt:play()

	--Flicker and make invulnerable for one second
	self:flicker(1)
	self:invulnOn()
	Timer:new(1, self, Player.invulnOff)
	General:getCamera():screenShake(.01, .5)
end

--[[ Update the health bar in the Hud
]]
function Player:updateHealth()
	--Width is relative to size of health bar (value is defined in GameState, hardcoded here)
	local hpWidth = (self.health/self.maxHealth) * 105
	if hpWidth < 0 then
		hpWidth = 0
	end
	GameState.hpBar.width = hpWidth
end
--[[ Update the shield bar in the Hud
]]
function Player:updateShield()
	local shieldWidth = (self.shield/self.maxShield) * 64
	if shieldWidth < 0 then
		shieldWidth = 0
	end
	GameState.shieldBar.width = shieldWidth
end

function Player:invulnOn()
	self.invuln = true
end

function Player:invulnOff()
	self.invuln = false
end

function Player:enableTransform()
	self.lockTransform = false
end
function Player:disableTransform()
	self.lockTransform = true
end

function Player:keypressed(Key)
	if Key == " " then
		--self.weapons[self.activeWeapon]:restart()
		self:attackStart()
	end
end

function Player:keyreleased(Key)
	if Key == " " then
		--self.weapons[self.activeWeapon]:stop()
		self:attackStop()
	elseif Key == "i" then
		self.invuln = true
	end
end

function Player:getType()
	return "Player"
end

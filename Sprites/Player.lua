Player = {
	weapons = {},
	weaponCasings = {},
	weaponFlashes = {},
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

function Player:new(X,Y)
	s = Sprite:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.weapons = {}
	s.weaponCasings = {}
	s.weaponFlashes = {}
	s.health = 3
	s.maxHealth = 3
	s.shield = 3
	s.maxShield = 3
	
	s.sfxHurtHealth = love.audio.newSource(LevelManager:getSound("player_hurt_health"))
	s.sfxHurtShield = love.audio.newSource(LevelManager:getSound("player_hurt_shield"))

	return s
end

function Player:addWeapon(GunEmitter, Slot, CasingEmitter, FlashEmitter)
	--if self.weapons == nil then
	--	self.weapons = Group:new()
	--end
	--self.weapons:add(GunEmitter)
	self.weapons[Slot] = GunEmitter
	if CasingEmitter ~= nil then
		self.weaponCasings[Slot] = CasingEmitter
	end
	if FlashEmitter ~= nil then
		self.weaponFlashes[Slot] = FlashEmitter
	end
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
		self:flash({0,174,239}, 1)
		self.sfxHurtShield:play()
		GameState.shieldMask:flicker(.2)
		GameState.shieldMask:flash({255,0,0}, .2)
		self:updateShield()
	else
		Sprite.hurt(self, Damage)
		self:flicker(1)
		self:flash({243,17,17}, .5)
		self.sfxHurtHealth:play()
		GameState.hpMask:flicker(.2)
		GameState.hpMask:flash({126,0,0}, .2)
		self:updateHealth()
	end
	

	--Flicker and make invulnerable for one second
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
	GameState.hpMask.scaleX = 1 - self.health/self.maxHealth
	
	if self.health <= 1 then
		GameState.hpBar:flash({128,0,0}, 1, true)
	end
end
--[[ Update the shield bar in the Hud
]]
function Player:updateShield()
	local shieldWidth = (self.shield/self.maxShield) * 64
	if shieldWidth < 0 then
		shieldWidth = 0
	end
	GameState.shieldMask.scaleX = 1 - self.shield/self.maxShield
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
	if Key == " " and self.activeMode == "ship" then
		self:attackStop()
	elseif Key == "i" then
		self.invuln = not self.invuln
		if self.invuln then
			self.color = {50,50,128}
		else
			self.color = {255,255,255}
		end
	end
end

function Player:getType()
	return "Player"
end

Player = {
	weapons = {},
	activeWeapon = 1,
	score = 0,
	enableControls = true,
	activeMode = nil,
	invuln = false,
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

function Player:kill()
	self.alive = false
	self.enableControls = false
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
end

function Player:hurt(Damage)
	if not self.invuln then
		Sprite.hurt(self, Damage)
		self.sfxHurt:play()
		local hpWidth = (self.health/self.maxHealth) * 105
		if hpWidth < 0 then
			hpWidth = 0
		end
		GameState.hpBar.width = hpWidth

		self:flicker(1)
		--self.health = self.health - Damage
		--if self.health <= 0 then
		--	Player:kill()
		--end
		self:invulnOn()
		Timer:new(1, self, Player.invulnOff)
		General:getCamera():screenShake(.01, .5)
	end
end

function Player:invulnOn()
	self.invuln = true
end

function Player:invulnOff()
	self.invuln = false
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


Player = {
	weapons = {},
	activeWeapon = 1,
	score = 0,
	enableControls = true
}

thump = love.audio.newSource("sounds/thump.mp3")

function Player:new(X,Y,ImageFile)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.weapons = {}

	return s
end

function Player:addWeapon(GunEmitter, Slot)
	--if self.weapons == nil then
	--	self.weapons = Group:new()
	--end
	--self.weapons:add(GunEmitter)
	self.weapons[Slot] = GunEmitter
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

function Player:keypressed(Key)
	if Key == " " then
		self.weapons[self.activeWeapon]:restart()
	end
end

function Player:keyreleased(Key)
	if Key == " " then
		--self.weapons[self.activeWeapon]:stop()
	end
end

function Player:getType()
	return "Player"
end


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
	
	s.magnitude = 400
	s.momentArm = math.sqrt(s.magnitude^2/2)
	s.weapons = {}

	return s
end

function Player:addWeapon(GunEmitter)
	--if self.weapons == nil then
	--	self.weapons = Group:new()
	--end
	--self.weapons:add(GunEmitter)
	self.weapons[1] = GunEmitter
end

function Player:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
	self:addAnimation("down_in", {2, 3, 4, 5}, .05, false)
	self:addAnimation("down_out", {6, 7, 8, 9}, .05, false)
	self:addAnimation("up_in", {12, 13, 14, 15}, .05, false)
	self:addAnimation("up_out", {16, 17, 18, 19}, .05, false)
	self:playAnimation("idle")
end

function Player:updateScore(S)
	self.score = self.score + S
end

function Player:getScore()
	return self.score
end

-- as of now you must use this method to change the magnitude
-- otherwise, the momentArm will not be recalculated
function Player:changeMagnitude(m)
	self.magnitude = m
	self.momentArm = math.sqrt(self.magnitude^2/2)
end
function Player:update()
	if self.enableControls then
		self.weapons[self.activeWeapon]:setPosition(self.x+self.width/2, self.y+12)
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
			self.velocityX = 0;
			self.velocityY = 0;
		end
		--Keep up with screen scrolling
		self.velocityX = self.velocityX + GameState.cameraFocus.velocityX
	end
	
	if self.velocityY > 0 then
		if self.curAnim.name == "up_in" then
			self:playAnimation("up_out", false, true)
		else
			self:playAnimation("down_in")
		end
	elseif self.velocityY < 0 then
		if self.curAnim.name == "down_in" then
			self:playAnimation("down_out", false, true)
		else
			self:playAnimation("up_in")
		end
	else
		if self.curAnim.name == "down_in" then
			self:playAnimation("down_out", false, true)
		end
		if self.curAnim.name == "up_in" then
			self:playAnimation("up_out", false, true)
		end
		self:playAnimation("idle")
	end
	
	Sprite.update(self)
end

function Player:keypressed(Key)
	if Key == " " then
		self.weapons[self.activeWeapon]:restart()
	end
end

function Player:keyreleased(Key)
	if Key == " " then
		self.weapons[self.activeWeapon]:stop()
	end
end

function Player:getType()
	return "Player"
end

return Player

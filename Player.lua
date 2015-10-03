Player = {
	score = 0
}

thump = love.audio.newSource("sounds/thump.mp3")

function Player:new(X,Y,ImageFile)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.magnitude = 400
	s.momentArm = math.sqrt(s.magnitude^2/2)
	return s
end

function Player:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, false)
	self:addAnimation("down", {5,6}, .1, false)
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
	if love.keyboard.isDown('w') and love.keyboard.isDown('d') then
        self:playAnimation("up")
        self.velocityX = self.momentArm
		self.velocityY = -self.momentArm
	elseif love.keyboard.isDown('d') and love.keyboard.isDown('s') then
		self:playAnimation("down")
        self.velocityX = self.momentArm
		self.velocityY = self.momentArm
	elseif love.keyboard.isDown('s') and love.keyboard.isDown('a') then
		self:playAnimation("down")
        self.velocityX = -self.momentArm
		self.velocityY = self.momentArm
	elseif love.keyboard.isDown('a') and love.keyboard.isDown('w') then
        self:playAnimation("up")
        self.velocityX = -self.momentArm
		self.velocityY = -self.momentArm
	elseif love.keyboard.isDown('w') then
        self:playAnimation("up")
		self.velocityX = 0
		self.velocityY = -self.magnitude
	elseif love.keyboard.isDown('s') then
		self:playAnimation("down")
        self.velocityX = 0
		self.velocityY = self.magnitude
	elseif love.keyboard.isDown('a') then
		self:playAnimation("up")
        self.velocityX = -self.magnitude
		self.velocityY = 0
	elseif love.keyboard.isDown('d') then
		self:playAnimation("down")
        self.velocityX = self.magnitude
		self.velocityY = 0
	else
		self:playAnimation("idle")
		self.velocityX = 0;
		self.velocityY = 0;
    end
	--Keep up with screen scrolling
	self.velocityX = self.velocityX + GameState.cameraFocus.velocityX
	
	if (self.touching == Sprite.UP) then
		thump:play()
	end
	if (self.touching == Sprite.DOWN) then
		thump:play()
	end
	if (self.touching == Sprite.LEFT) then
		thump:play()
	end
	if (self.touching == Sprite.RIGHT) then
		thump:play()
	end

	Sprite.update(self)
end

function Player:getType()
	return "Player"
end

return Player

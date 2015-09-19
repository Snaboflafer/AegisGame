Player = {}

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
	self:addAnimation("idle", {1}, 1, false)
	self:addAnimation("up", {2}, 1, false)
	self:addAnimation("down", {3}, 1, false)
end

-- as of now you must use this method to change the magnitude
-- otherwise, the momentArm will not be recalculated
function Player:changeMagnitude(m)
	self.magnitude = m
	self.momentArm = math.sqrt(self.magnitude^2/2)
end
function Player:update()
	self:playAnimation("idle")
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
        self.velocityX = -self.magnitude
		self.velocityY = 0
	elseif love.keyboard.isDown('d') then
        self.velocityX = self.magnitude
		self.velocityY = 0
	else
		self.velocityX = 0;
		self.velocityY = 0;
    end
	
	Sprite.update(self)
	
	if (touchingU) or (touchingD) or (touchingL) or (touchingR) then
		thump:play()
		if (touchingU) then
			self.y = self.y + 10
		end
		if (touchingD) then
			self.y = self.y - 10
		end
		if (touchingL) then
			self.x = self.x + 10
		end
		if (touchingR) then
			self.x = self.x - 10
		end
	end
end

function Player:getType()
	return "Player"
end

return Player

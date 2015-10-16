--Class for sprites. Should extend Object
Enemy = {
	pointValue = 0,
	massless = true,
	route = 0,
	attackPower = 1
}

function Enemy:new(X,Y,ImageFile)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.route = math.floor(math.random()*3)
	return s
end

function Enemy:kill()
	GameState.effect:play("explosion", self.x, self.y)
	Sprite.kill(self)
end

function Enemy:respawn(SpawnX, SpawnY)
	self.lifetime = 0
	self.x = SpawnX
	self.y = SpawnY
	self.route = math.floor(math.random()*3)
	self.velocityX = 0
	self.velocityY = 0
	self.accelerationX = 0
	self.accelerationY = 0
	self.exists = true
end


function Enemy:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, true)
	self:addAnimation("down", {5,6}, .1, true)
end

function Enemy:setPointValue(V)
	self.pointValue = V
end

function Enemy:getPointValue()
	return self.pointValue
end

function Enemy:update()
	if self.route == 0 and self:onScreen() == true then
		self.accelerationY = 400*math.cos(5*self.lifetime)
	elseif self.route == 1 then
		if self.lifetime < 2 and self:onScreen() == true then
			self.accelerationY = -50
		else
			self.accelerationY = 15
			self.accelerationX = -100
		end
	elseif self.route == 2 then
		if self.lifetime < 2 and self:onScreen() == true then
			self.accelerationY = 50
		else
			self.accelerationY = -15
			self.accelerationX = -100
		end
	end
	
	if self.velocityY < 50 then
		self:playAnimation("up")
	elseif self.velocityY > 50 then
		self:playAnimation("down")
	else
		self:playAnimation("idle")
	end
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Sprite.update(self)
end

function Enemy:getType()
	return "Enemy"
end

return Enemy	
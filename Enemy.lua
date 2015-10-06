--Class for sprites. Should extend Object
Enemy = {
	pointValue = 0,
	massless = true
}

function Enemy:new(X,Y,ImageFile)
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.maxVelocityX = 150
	s.maxVelocityY = 150
	return s
end

function Enemy:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, true)
	self:addAnimation("down", {5,6}, .1, true)
end

function Enemy:setEmitter(newEmitter)
	self.emitter = newEmitter
	self.emitter:start(false, 1, .1)
	self.emitter:setSpeedRange(200,200)
end

function Enemy:setPointValue(V)
	self.pointValue = V
end

function Enemy:getPointValue()
	return self.pointValue
end

function Enemy:shootBullet(aimx, aimy)
	self.emitter:setPosition(self.x, self.y)
	local dx = aimx - self.x
	local dy = aimy - self.y
	self.emitter:setAngle(math.atan(dy/dx), 0)
end

function Enemy:update()
	self.accelerationX = (math.random() - 0.5)*1000
	self.accelerationY = (math.random() - 0.5)*1000
	
	
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
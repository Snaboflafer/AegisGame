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

function Enemy:setPointValue(V)
	self.pointValue = V
end

function Enemy:getPointValue()
	return self.pointValue
end

function Enemy:shootBullet(bullet, aimx, aimy)
	local distance = math.sqrt((aimx - self.x)^2 + (aimy - self.y)^2)
	local vx = (aimx - self.x)/distance*100
	local vy = (aimy - self.y)/distance*100
	bullet:reset(self.x, self.y, vx, vy)
end

function Enemy:update()
	self.accelerationX = (math.random() - 0.5)*1000
	self.accelerationY = (math.random() - 0.5)*1000
	Sprite.update(self)
	if touchingU or touchingD then self.velocityY = -self.velocityY end
	if touchingR or touchingL then self.velocityX = -self.velocityX end
	
	if self.velocityY < 50 then
		self:playAnimation("up")
	elseif self.velocityY > 50 then
		self:playAnimation("down")
	else
		self:playAnimation("idle")
	end
end

function Enemy:getType()
	return "Enemy"
end

return Enemy	
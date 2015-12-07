
Projectile = {
	persists = false	--Projectile is not kiled after a collision
}

function Projectile:new(X, Y, Image)
	s = Sprite:new(X,Y, Image)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.persists = false
	s.friction = 1
	s.massless = true
	
	return s
end

function Projectile:kill()
	if self.animated then
		self.alive = false
	else
		Sprite.kill(self)
	end
end

function Projectile:update()
	if self.alive then
		self.solid = true
		if self.animated then
			self:playAnimation("default")
		end
	else
		self.solid = false
		if self.animated then
			self:playAnimation("kill")
			if self.animFinished then
				Sprite.kill(self)
			end
		else
			Sprite.kill(self)
		end
	end

	Sprite.update(self)
	
end

function Projectile:collide()
	if not self.persists then
		self:kill()
	end
end

function Projectile:setPersistance(Enable)
	self.persists = Enable
	self.immovable = true
end

function Projectile:getType()
	return "Projectile"
end
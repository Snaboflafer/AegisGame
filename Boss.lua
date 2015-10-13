--Class for sprites. Should extend Object
Boss = {
	weapons = {}
}

function Boss:new(X,Y,ImageFile)
	s = Enemy:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.route = 0
	s.velocityX = GameState.cameraFocus.velocityX
	s.health = 20
	return s
end

function Boss:addWeapon(GunGroup)
	table.insert(self.weapons, GunGroup)
end

function Boss:update()
	if self.route == 0 then 
		if self.lifetime < 4 then
			self.accelerationX = - 40
		elseif self.lifetime > 8 then
			self.lifetime = 0
			self.route = 1
		else
			self.accelerationX = 40
		end
	elseif self.route == 1 then
		if self.lifetime < 2 then
			self.accelerationX = -40
		elseif self.lifetime < 6 then
			self.accelerationX = 40
		elseif self.lifetime < 8 then
			self.accelerationX = -40
		else
			self.lifetime = 0
		end
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

function Boss:getType()
	return "Boss"
end

return Boss	
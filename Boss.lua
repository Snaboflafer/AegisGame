--Class for sprites. Should extend Object
Boss = {
	weapons = {}
}

function Boss:new(X,Y,ImageFile)
	s = Enemy:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self
	s.route = 0
	s.velocityX = GameState.cameraFocus.velocityX
	s.health = 20
	return s
end

function Boss:respawn(SpawnX, SpawnY)
	self.lifetime = 0
	self.x = SpawnX
	self.y = SpawnY
	self.route = math.floor(math.random()*3)
	self.route = 0
	self.velocityX = GameState.cameraFocus.velocityX
	self.velocityY = 0
	self.accelerationX = 0
	self.accelerationY = 0
	self.health = 20
	self.exists = true
end

function Boss:addWeapon(GunGroup)
	self.weapons = GunGroup
end

function Boss:update()
	self.velocityX = GameState.cameraFocus.velocityX
	if self.route == 0 then 
		i = 0
		for k, v in pairs(self.weapons.members) do 
		v:setAngle(120+self.lifetime*15 + i*10, 0)
		i = i + 1
		end
		if self.lifetime < 8 then
			self.velocityX = self.velocityX - 40
		else
			self.lifetime = 0
			self.route = 1
		end
	elseif self.route == 1 then
		if self.lifetime < 4 then
			i = 1
			for k, v in pairs(self.weapons.members) do 
				v:setAngle((self.lifetime+1)*40*i, 0)
				i = i + 1
			end
			self.velocityX = self.velocityX - 40
		elseif self.lifetime < 8 then
			i = 0
			for k, v in pairs(self.weapons.members) do 
				v:setAngle(self.lifetime*30 + i*10, 0)
				i = i + 1
			end
			self.velocityX = self.velocityX + 40
		else
			self.lifetime = 0
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
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
	s.health = 20
	s.immovable = true
	return s
end

function Boss:respawn(SpawnX, SpawnY)
	self.lifetime = 0
	self.x = SpawnX
	self.y = SpawnY
	self.route = math.floor(math.random()*3)
	self.route = 0
	self.velocityY = 0
	self.accelerationX = 0
	self.accelerationY = 0
	self.health = 20
	self.exists = true
end

function Boss:setPointValue()
end

function Boss:hurt(Damage)
	Sprite.hurt(self, Damage)
	self:flicker(.1)
end

function Boss:addWeapon(GunGroup, slot)
	self.weapons[slot] = GunGroup
end

function Boss:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, true)
	self:addAnimation("down", {5,6}, .1, true)
end

function Boss:update()
	self.velocityX = 2*(General:getCamera().x + General.screenW*3/4 - self.x)

	if self.route == 0 then 
		i = 0
		for k, v in pairs(self.weapons[0].members) do 
			v:setAngle(120+self.lifetime*15 + i*10, 0)
		i = i + 1
		end
		if self.lifetime > 8 then
			self.lifetime = 0
			self.route = 1
		end
	elseif self.route == 1 then
		if self.lifetime < 4 then
			i = 0
			for k, v in pairs(self.weapons[0].members) do 
				v:setAngle(100 + self.lifetime*12 + i*50, 0)
				i = i + 1
			end
		elseif self.lifetime < 8 then
			i = 0
			for k, v in pairs(self.weapons[0].members) do 
				v:setAngle(self.lifetime*40 + i*10 - 60, 0)
				i = i + 1
			end
		else
			self.lifetime = 0
			self.route = 2
			for k, v in pairs(self.weapons[0].members) do 
				v:stop()
			end
			for k, v in pairs(self.weapons[1].members) do 
				v:restart()
			end
		end
	elseif self.route == 2 then
		for k, v in pairs(self.weapons[1].members) do 
			v:setAngle(200+self.lifetime*5, 0)
		end
		if self.lifetime > 8 then
			self.lifetime = 0
			self.route = 1
			for k, v in pairs(self.weapons[1].members) do 
				v:stop()
			end
			for k, v in pairs(self.weapons[0].members) do 
				v:restart()
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
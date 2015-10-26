--Class for sprites. Should extend Object
Enemy3 = {
}

function Enemy3:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.route = 1
	s.health = 0.5
	s.maxHealth = 0.5
	s.NUMROUTES = 1
	s.attackPower = 1
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy3:setAnimations()
	self:addAnimation("idle", {1,2,3,4}, .1, true)
	self:addAnimation("foward", {5,6,7,8}, .1, true)
end

function Enemy3:update()


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
	
	if self.velocityX < 0 then
		self:playAnimation("forward")
	end
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Enemy.update(self)
end

function Enemy3:getType()
	return "Enemy3"
end

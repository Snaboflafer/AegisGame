--Class for sprites. Should extend Object
Enemy1 = {
}

function Enemy1:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.route = math.floor(math.random()*3)
	s.health = 1
	s.maxHealth = 1
	s.NUMROUTES = 3
	s.attackPower = 1
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy1:setAnimations()
	self:addAnimation("idle", {1,2}, .1, true)
	self:addAnimation("up", {3,4}, .1, true)
	self:addAnimation("down", {5,6}, .1, true)
end

function Enemy1:update()
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

	Enemy.update(self)
end

function Enemy1:getType()
	return "Enemy1"
end

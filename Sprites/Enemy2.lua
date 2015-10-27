--Class for sprites. Should extend Object
Enemy2 = {
	maxVelocityX = 200
}

function Enemy2:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.route = math.floor(math.random()*1)
	s.health = 2
	s.maxHealth = 2
	s.NUMROUTES = 1
	s.attackPower = 1
	--s.accelerationY = 200
	s.y = General.screenH - 200
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy2:setAnimations()
	self:addAnimation("idle_0",   {1,2}, .1, true)
	self:addAnimation("fire_0",  {3}, .5, false)
	self:addAnimation("idle_10",  {4,5}, .1, true)
	self:addAnimation("fire_10", {6}, .5, false)
	self:addAnimation("idle_20",  {7,8}, .1, true)
	self:addAnimation("fire_20", {9}, .5, false)
	self:addAnimation("idle_30",  {10,11}, .1, true)
	self:addAnimation("fire_30", {12}, .5, false)
	self:addAnimation("idle_35",  {13,14}, .1, true)
	self:addAnimation("fire_35", {15}, .5, false)
end

function Enemy2:update()
	if self.aiStage == 1 then
		self.accelerationX = math.random()*50
		if self:getScreenX() < General.screenW * .8 then
			--self.aiStage = self.aiStage + 1
		end
	elseif self.aiStage == 2 then
		self:kill()
	end
	--if self.route == 0 and self:onScreen() == true then
	--	self.accelerationY = 400*math.cos(5*self.lifetime)
	--elseif self.route == 1 then
	--	if self.lifetime < 2 and self:onScreen() == true then
	--		self.accelerationY = -50
	--	else
	--		self.accelerationY = 15
	--		self.accelerationX = -100
	--	end
	--elseif self.route == 2 then
	--	if self.lifetime < 2 and self:onScreen() == true then
	--		self.accelerationY = 50
	--	else
	--		self.accelerationY = -15
	--		self.accelerationX = -100
	--	end
	--end
	--
	self:playAnimation("idle_0")
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Enemy.update(self)
end

function Enemy2:getType()
	return "Enemy2"
end

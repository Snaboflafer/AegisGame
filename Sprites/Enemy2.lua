--Class for sprites. Should extend Object
Enemy2 = {
	maxVelocityX = 100,
	weapon = {}
}

function Enemy2:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.aiStage = 1
	s.health = 2
	s.maxHealth = 2
	s.score = 200
	s.NUMROUTES = 1
	s.attackPower = 1
	--s.accelerationY = 200
	s.y = General.screenH - 200
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy2:setWeapon(Gun)
	self.weapon = Gun
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
	local actualAngle = math.asin((self.y - GameState.player.y)/(self.x - GameState.player.x))*180/math.pi
	local weaponAngle = 0
	if (GameState.player.activeMode == "mech") then
		weaponAngle = actualAngle
	else
		weaponAngle = math.asin((self.y - GameState.player.y)/(self.x - GameState.player.x - GameState.cameraFocus.velocityX))*180/math.pi
	end
	if self.aiStage == 1 then
		if self:getScreenX() <= General.screenW - 200 then
			self.aiStage = self.aiStage + 1
			self.lifetime = 0
			self.weapon:restart()
			self.weapon:setAngle(180 - weaponAngle, 0)
			self.weapon:setSpeed(100,150)
		end
		if actualAngle < 10 then
			self:playAnimation("idle_0")
		elseif actualAngle < 20 then
			self:playAnimation("idle_10")
		elseif actualAngle < 30 then
			self:playAnimation("idle_20")
		elseif actualAngle < 35 then
			self:playAnimation("idle_30")
		else
			self:playAnimation("idle_35")
		end
	elseif self.aiStage == 2 then
		self.weapon:setAngle(180 - weaponAngle, 0)
		if self.lifetime > 4 then
			self.aiStage = self.aiStage + 1
		end
		self.x = General:getCamera().x + General.screenW - 200
		if actualAngle < 10 then
			self:playAnimation("fire_0")
		elseif actualAngle < 20 then
			self:playAnimation("fire_10")
		elseif actualAngle < 30 then
			self:playAnimation("fire_20")
		elseif actualAngle < 35 then
			self:playAnimation("fire_30")
		else
			self:playAnimation("fire_35")
		end
	else
		s.velocityX = 0
		self.weapon:stop()
		self:playAnimation("idle_0")
	end
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Enemy.update(self)
end

function Enemy2:getType()
	return "Enemy2"
end

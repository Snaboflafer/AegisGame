--Class for third type of enemy sprites
Enemy4 = {
}

function Enemy4:new(X,Y)
	s = Enemy:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Enemy)
	self.__index = self

	s.health = 4
	s.maxHealth = 0
	s.score = 50
	s.NUMROUTES = 1
	s.attackPower = 1
	s.maxVelocityY = 200
	s.accelerationY = 50
	
	s.sfxHurt = love.audio.newSource(LevelManager:getSound("hurt_2"))
	
	return s
end

function Enemy4:setAnimations()
	self:addAnimation("idle", {1}, 0, false)
	self:addAnimation("blink", {1,2,1}, .2, true)
	self:addAnimation("prime", {2,3,4,5,6,7,8,9,10,11,12,13,14}, .08, true)
	self:addAnimation("activate", {5,2}, .05, false)
end

function Enemy4:update()
	if self.aiStage == 1 then
	
	elseif self.aiStage == 2 then

	else

	end
	self:playAnimation("prime")
	
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end

	Enemy.update(self)
end

function Enemy4:getType()
	return "Enemy4"
end

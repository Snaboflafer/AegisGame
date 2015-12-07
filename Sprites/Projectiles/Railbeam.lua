
Railbeam = {
	MULTIHIT_SCORE = 200,
	beamTrail = nil,
	impactSparks = nil,
	health = 1,
	maxHealth = 1
}

function Railbeam:new(X, Y)
	s = Projectile:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Projectile)
	self.__index = self
	
	s.health = 2
	s.maxHealth = 2
	
	return s
end

function Railbeam:setAnimations()
	--No animations to set
	return
end


function Railbeam:doConfig()
	self:setPersistance(true)
	self.killOffScreen = false

	self:loadSpriteSheet(LevelManager:getParticle("bullet-orange"), 20, 20)
	self:setCollisionBox(-5,-5,32,32)
	self:addAnimation("default", {1}, 0, false)
	self:addAnimation("kill", {2,3,4,5}, .02, false)
	self:playAnimation("default")
	self.attackPower = 1.7
	self.visible = false
	self.massless = true
	
	--GameState.playerBullets:add(self)
	GameState.worldParticles:add(self)
	
	self.beamTrail = Emitter:new()
	for i=1, 30 do
		--Create the trail sprites
		local curBeam = Sprite:new(0,0)
		curBeam:loadSpriteSheet(LevelManager:getParticle("railLaser"), 48, 16)
		curBeam:addAnimation("default", {1,2,3,4,5,6}, .1+math.random()*.1, false)
		curBeam:playAnimation("default")
		curBeam.originX = curBeam.width/2
		curBeam.originY = curBeam.height/2
		self.beamTrail:addParticle(curBeam)
		curBeam.killOffScreen = false
	end
	--Set fire trail parameters
	self.beamTrail:setSpeed(15,20)
	self.beamTrail:setGravity(10)
	self.beamTrail:setRadial(true)
	self.beamTrail:lockParent(self, true)
	self.beamTrail:start(false, 1, .01, -1)
	--self.beamTrail:stop()
	
	GameState.emitters:add(self.beamTrail)
	
	self.impactSparks = Emitter:new()
	for i=1, 10 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("thruster"), 16, 8)
		curParticle:addAnimation("default", {1,2,3,4}, .1, true)
		curParticle:playAnimation("default")
		curParticle.originX = curParticle.width/2
		curParticle.originY = curParticle.height/2
		curParticle.color = {0,184,255}
		self.impactSparks:addParticle(curParticle)
	end
	self.impactSparks:setSpeed(100, 350)
	self.impactSparks:setOffset(10)
	self.impactSparks:setSize(32,32)
	self.impactSparks:setGravity(400)
	self.impactSparks:setRadial(true)
	self.impactSparks:start(true, .5, .02, -1)
	self.impactSparks:stop()
	self.impactSparks:lockParent(self, false)
	GameState.emitters:add(self.impactSparks)

end

function Railbeam:update()
	self.beamTrail:setAngle(-self.angle * 180/math.pi, 2)

	Projectile.update(self)
end

function Railbeam:collide()
	self.impactSparks:setAngle(-self.angle * 180/math.pi, 30)
	self.impactSparks:restart()
	
	if self.health <= 0 then
		GameState.shieldBreak:play(self.x, self.y)
		GameState.score = GameState.score + self.MULTIHIT_SCORE
		Projectile.kill(self)
	end
	--Projectile.collide(self)
end

function Railbeam:getType()
	return "Railbeam"
end
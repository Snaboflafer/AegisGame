Effect = {
	exists = true,
	active = true,
	visible = true,
	solid = false,
	emitters = {},
	sprite = nil,
	effectType = ""
}

function Effect:new(ImageFile)
	s = {}
	setmetatable(s, self)
	self.__index = self

	
	s.sfxExplosion = love.audio.newSource(LevelManager:getSound("explosion"))

	return s
end

--[[ Register the effect as an explosion
]]
function Effect:initExplosion()
	self.effectType = "explosion"
	
	--Create base sprite
	self.sprite = Sprite:new(0,0)
	self.sprite:loadSpriteSheet(LevelManager:getImage("explosion"), 64,64)
	self.sprite:addAnimation("default", {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}, 0.01, false)
	self.sprite.exists = false
	
	--Create particle system
	local explosion = Emitter:new()
	for i=1, 24 do
		--Create invisible fireball objects to be used for explosions
		--(Enough for 3 concurrent explosions)
		local fireball = Sprite:new(0,0)
		fireball.visible = false
		explosion:addParticle(fireball)
		
		--Create and attach trail (fire/smoke) to each fireball
		local fireTrail = Emitter:new()
		for i=1, 10 do
			--Create the actual trail sprites
			local curParticle = Sprite:new(0,0)
			curParticle:loadSpriteSheet(LevelManager:getParticle("fireball"), 32, 32)
			curParticle:addAnimation("default", {1,2,3,4,5,6,7,7,8,8,9,9,9,9,10}, .08, false)
			curParticle:playAnimation("default")
			fireTrail:addParticle(curParticle)
		end
		--Set fire trail parameters
		fireTrail:setSpeed(10)
		fireTrail:setGravity(-50)
		fireTrail:lockParent(fireball, true)
		fireTrail:start(false, 1, .05, -1)
		fireTrail:stop()
		GameState.emitters:add(fireTrail)
		
	end
	--Set explosion burst parameters
	explosion:setSpeed(100)
	explosion:setGravity(100)
	explosion:setDrag(20, 0)
	explosion:lockParent(self.sprite, false)
	explosion:start(true, 1, 0, 8)
	explosion:stop()
	table.insert(self.emitters,explosion)
	
	--Create leftover smoke
	local smokeBurst = Emitter:new()
	for i=1, 20 do
		local smokeParticle = Sprite:new(0,0)
		smokeParticle:loadSpriteSheet(LevelManager:getParticle("smoke"), 32, 32)
		smokeParticle:addAnimation("default", {1,1,1,2,3,4,3,2,1}, .01, false)
		smokeParticle:playAnimation("default")
		smokeBurst:addParticle(smokeParticle)
	end
	smokeBurst:setSpeed(0,50)
	smokeBurst:setGravity(-10)
	smokeBurst:lockParent(self.sprite, false)
	smokeBurst:start(true, 2, 0, 10)
	smokeBurst:stop()
	table.insert(self.emitters, smokeBurst)
	--self.playerShip:addWeapon(playerGun, 1)
end

function Effect:destroy()
	self.sprite = nil
	for i=1, table.getn(self.emitters) do
		self.emitters[i]=nil
	end
	self.emitters = nil
end

function Effect:update()
	local effectSprite = self.sprite
	if effectSprite ~= nil then
		if effectSprite.exists and effectSprite.active then
			effectSprite:update()
		end
	end
	
	for k,v in pairs(self.emitters) do
		if v.exists and v.active then
			v:update()
		end
	end
end

function Effect:draw()
	local effectSprite = self.sprite
	if effectSprite ~= nil then
		if effectSprite.exists and effectSprite.visible then
			effectSprite:draw()
		end
	end
	
	for k,v in pairs(self.emitters) do
		if v.exists and v.visible then
			v:draw()
		end
	end
end

function Effect:play(X, Y)
	self.exists = true
	self.sprite.exists = true
	self.sprite:setPosition(X, Y)
	self.sprite:playAnimation("default", true)
	for k,v in pairs(self.emitters) do
		v:restart()
	end
	self.sfxExplosion:rewind()
	self.sfxExplosion:play()
end

function Effect:getType()
	return "Effect"
end

function Effect:getDebug()
	debugStr = ""
	debugStr = debugStr .. "Explosion (" .. self.effectType .. "):\n"
	if self.sprite ~= nil then
		debugStr = debugStr .. self.sprite:getDebug()
	end
	
	return debugStr
end

--Class for sprites. Should extend Object
Pickup = {
	NUM_PICKUPS = 4,
	id = 1,
	score = 200,
	sfx = nil,
	focusEmitter = nil
}

function Pickup:new(X,Y, Id)
	s = Sprite:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.maxVelocityY = 100
	s.accelerationY = 20
	
	s.id = Id or 1
	while (s.id == 1 and GameState.player.health == GameState.player.maxHealth) or
			(s.id == 2 and GameState.player.shield == GameState.player.maxShield) do
		s.id = math.random(1, Pickup.NUM_PICKUPS)
	end
	
	return s
end

function Pickup:doConfig()
	self:loadSpriteSheet(LevelManager:getImage("powerup"), 32,32)
	self:addAnimation("health",	{1}, 0, false)
	self:addAnimation("shield",	{2}, 0, false)
	self:addAnimation("power",	{3}, 0, false)
	self:addAnimation("spread",	{4}, 0, false)
	self:addAnimation("OTHER",	{5}, 0, false)

	self:setCollisionBox(-8,-8, 48, 48)
	
	self.massless = true
	self:flash({127,127,127}, .5, true)
	
	local color =  {255, 255, 255}
	if self.id == 1 then
		self:playAnimation("health")
		self.sfx = love.audio.newSource(LevelManager:getSound("powerup_health"))
		color =  {243, 17, 17}
	elseif self.id == 2 then
		self:playAnimation("shield")
		self.sfx = love.audio.newSource(LevelManager:getSound("powerup_shield"))
		color =  {0, 174, 239}
	elseif self.id == 3 then
		self:playAnimation("power")
		self.sfx = love.audio.newSource(LevelManager:getSound("powerup_power"))
		color =  {255, 151, 35}
	elseif self.id == 4 then
		self:playAnimation("spread")
		self.sfx = love.audio.newSource(LevelManager:getSound("powerup_alt"))
		color =  {9, 251, 9}
	else
		self:playAnimation("OTHER")
	end
	
	self.focusEmitter = Emitter:new()
	for i=1, 10 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("thruster"), 16, 8)
		curParticle:addAnimation("default", {1,2,3,4}, .1, true)
		curParticle:playAnimation("default")
		curParticle.originX = curParticle.width/2
		curParticle.originY = curParticle.height/2
		curParticle.color = color
		self.focusEmitter:addParticle(curParticle)
	end
	self.focusEmitter:setSpeed(-100, -350)
	self.focusEmitter:setOffset(32)
	--self.focusEmitter:setSize(32,32)
	self.focusEmitter:setRadial(true)
	self.focusEmitter:start(false, .1, .02, -1)
	self.focusEmitter:lockParent(self, false)
	GameState.emitters:add(self.focusEmitter)
end

--[[ applies a powerup
]]
function Pickup:apply(PlayerObject, PickupObject)
	if PickupObject.id == 1 then 
		-- adds health
		Sprite.hurt(PlayerObject,-1)
		if (PlayerObject.health > PlayerObject.maxHealth) then
			PlayerObject.health = PlayerObject.maxHealth
		end
		PlayerObject:flash({243,17,17},.3)
		GameState.hpMask:flicker(.2)
		GameState.hpMask:flash({126,0,0}, .2)
		PlayerObject:updateHealth()
	elseif PickupObject.id == 2 then 
		-- adds shield
		Sprite.hurt(PlayerObject,-3, "shield")
		if (PlayerObject.shield > PlayerObject.maxShield) then
			PlayerObject.shield = PlayerObject.maxShield
		end
		PlayerObject:flash({0,174,239},.3)
		GameState.shieldMask:flicker(.2)
		GameState.shieldMask:flash({0,0,126}, .2)
		PlayerObject:updateShield()
	elseif PickupObject.id == 3 then
		-- uses second weapon
		PlayerObject:setActiveWeapon(2)
		Player.specialAmmo = 10
		Player.specialMaxAmmo = 10
		Player:updateSpecial()
	elseif PickupObject.id == 4 then
		-- uses third weapon
		PlayerObject:setActiveWeapon(3)
		Player.specialAmmo = 10
		Player.specialMaxAmmo = 10
		Player:updateSpecial()
	end
	
	if PickupObject.sfx ~= nil then
		PickupObject.sfx:rewind()
		PickupObject.sfx:play()
	end
	
	GameState.score = GameState.score + PickupObject.score
	PickupObject:kill()
end

function Pickup:kill()
	self.focusEmitter.exists = false
	self.focusEmitter:destroy()
	Sprite.kill(self)
	Sprite.destroy(self)
end

function Pickup:update()
	Sprite.update(self)
	if self:getScreenX() + self.width < 0 then
		self:kill()
	end
end

function Pickup:getType()
	return "Pickup"
end

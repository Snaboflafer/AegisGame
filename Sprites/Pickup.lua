--Class for sprites. Should extend Object
Pickup = {
	NUM_PICKUPS = 4,
	id = 1,
	massless = true,
	score = 200
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

	self.massless = true
	self:flash({127,127,127}, .5, true)
	if self.id == 1 then
		--self:createGraphic(32,32,{243,17,17},255)
		--self:loadImage(LevelManager:getParticle("bullet-red"))
		self:playAnimation("health")
	elseif self.id == 2 then
		--self:createGraphic(32,32,{0,174,239},255)
		--self:loadImage(LevelManager:getParticle("bullet-red"))
		self:playAnimation("shield")
	elseif self.id == 3 then
		--self:createGraphic(32,32,{0,255,0},255)
		--self:loadImage(LevelManager:getParticle("bullet-red"))
		self:playAnimation("power")
	elseif self.id == 4 then
		--self:createGraphic(32,32,{127,127,0},255)
		--self:loadImage(LevelManager:getParticle("bullet-red"))
		self:playAnimation("spread")
	else
		self:playAnimation("OTHER")
	end
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
		Sprite.hurt(PlayerObject,-1, "shield")
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
		Player.powerupTime = 10
		Player.powerupMaxTime = 10
	elseif PickupObject.id == 4 then
		-- uses third weapon
		PlayerObject:setActiveWeapon(3)
		Player.powerupTime = 10
		Player.powerupMaxTime = 10
	end
	
	GameState.score = GameState.score + PickupObject.score
	PickupObject:kill()
end

function Pickup:update()
	Sprite.update(self)
	if self:getScreenX() + self.width < 0 then
		self:setExists(false)
	end
end

function Pickup:getType()
	return "Pickup"
end

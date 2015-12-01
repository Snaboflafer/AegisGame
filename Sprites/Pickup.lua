--Class for sprites. Should extend Object
Pickup = {
	massless = true,
	NUM_PICKUPS = 4,
	id = 1
}

function Pickup:new(X,Y, Id)
	s = Sprite:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	s.maxVelocityY = 150
	s.accelerationY = 50
	s.id = Id or 1
	return s
end

function Pickup:doConfig()
	self.massless = true
	self:flash({127,127,127}, .5, true)
	if self.id == 1 then
		--self:createGraphic(32,32,{243,17,17},255)
		self:loadImage(LevelManager:getParticle("bullet-red"))
	elseif self.id == 2 then
		--self:createGraphic(32,32,{0,174,239},255)
		self:loadImage(LevelManager:getParticle("bullet-red"))
	elseif self.id == 3 then
		--self:createGraphic(32,32,{0,255,0},255)
		self:loadImage(LevelManager:getParticle("bullet-red"))
	elseif self.id == 4 then
		--self:createGraphic(32,32,{127,127,0},255)
		self:loadImage(LevelManager:getParticle("bullet-red"))
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
		PlayerObject.activeWeapon = 2
		Timer:new(10, PlayerObject, Player.resetWeapon)
	elseif PickupObject.id == 4 then
		-- uses third weapon
		PlayerObject.activeWeapon = 3
		Timer:new(10, PlayerObject, Player.resetWeapon)
	end
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

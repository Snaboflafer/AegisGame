GameState = {
	loaded = false,
	CAMERASCROLLSPEED = 200,
	playerGroundMode = false,
	score = 0,
	lastTrigger = 0,
	curTriggerIndex = 0
}	
GameState.__index = GameState
setmetatable(GameState, State)

function GameState:load()
	State.load(self)
	LevelManager:parseJSON("game.json")

	--Create camera
	self.camera = General:newCamera(0,0)
	self.camera:setBounds(0, -32, General.screenW + 32, General.screenH)
	GameState:add(self.camera)
	
	self.cameraFocus = Sprite:new(General.screenW/2, General.screenH/2)
	self.cameraFocus.velocityX = self.CAMERASCROLLSPEED
	self.cameraFocus:setVisible(false)
	self.cameraFocus.showDebug = true
	GameState:add(self.cameraFocus)

	self.wrappingSprites = Group:new()

	local currentLevel = General:getCurrentLevel()

	--Create background
	for i=0, 1, 1 do 
		local spriteBg = Sprite:new(i * 960, -64, LevelManager:getLevelBackground(currentLevel))
		self.wrappingSprites:add(spriteBg)
	end

	--Create floor
	self.ground = Group:new()
	for i=0, 4 do 
		local floorBlock = Sprite:new(i * 256, General.screenH- 128, LevelManager:getLevelFloor(currentLevel))
		floorBlock:setCollisionBox(0,30, 300, 198)
		floorBlock.immovable = true
		self.ground:add(floorBlock)
		--self.wrappingSprites:add(floorBlock)
	end
	--self.wrappingSprites:add(self.ground) (Nested groups not yet fully supported)
	
	GameState:add(self.wrappingSprites)
	GameState:add(self.ground)
		
	--Collision test sprite
	self.collisionSprite = Sprite:new(200,200,"images/button_256x64.png")
	self.collisionSprite:setCollisionBox(0,0,300,64)
	self.collisionSprite:lockToScreen(Sprite.ALL)
	--self.collisionSprite:setExists(false)
	GameState:add(self.collisionSprite)
	

	--Set up effects
	self.effect = Effect:new("images/explosion.png")
	self.effect:initialize("explosion", "images/explosion.png",64,64)
	self.effect:play("explosion",-128,-128)
	GameState:add(self.effect)
	
	--Set up particles
	self.emitters = Group:new()

	
	--Create player (flying)
	local image, height, width = LevelManager:getPlayerShip()
	self.playerShip = PlayerShip:new(100, 100)
	self.playerShip:loadSpriteSheet(image, height, width)
	self.playerShip:setAnimations()
	self.playerShip:setCollisionBox(46, 34, 91, 20)
	self.playerShip:lockToScreen(Sprite.ALL)
	self.playerShip.showDebug = true
	GameState:add(self.playerShip)
	
	local playerGun = Emitter:new(0,0)
	self.playerBullets = Group:new()
	for i=1, 5 do
		local curParticle = Sprite:new(0,0,"images/particles/laser.png")
		curParticle.attackPower = 1
		playerGun:addParticle(curParticle)
		self.playerBullets:add(curParticle)
	end
	playerGun:setSpeed(1000)
	playerGun:setAngle(0,0)
	playerGun:lockParent(self.playerShip, false)
	playerGun:setSound("sounds/laser.wav")
	playerGun:start(false, 3, .3, -1)
	playerGun:stop()
	self.emitters:add(playerGun)
	self.playerShip:addWeapon(playerGun, 1)
	
	
	local jetLocations = {{-22, -16},{-26, 25}}
	for i=1, table.getn(jetLocations) do
		local jetTrail = Emitter:new(0, 0)
		for j=1, 20 do
			local curParticle = Sprite:new(0, 0)
			curParticle:loadSpriteSheet(LevelManager:getParticle("trail"), 8,3)
			curParticle:addAnimation("idle", {1,2,3,4}, .08, false)
			curParticle:playAnimation("idle")
			jetTrail:addParticle(curParticle)
		end
		jetTrail:setSpeed(70, 150)
		jetTrail:setAngle(180)
		jetTrail:lockParent(self.playerShip, true, jetLocations[i][1], jetLocations[i][2])
		jetTrail:start(false, .3, 0)
		self.emitters:add(jetTrail)
	end

	image, height, width = LevelManager:getPlayerMech()

	self.playerMech = PlayerMech:new(100,100)
	self.playerMech:loadSpriteSheet(image, height, width)
	self.playerMech:setAnimations()
	self.playerMech:setCollisionBox(68, 44, 50, 104)
	self.playerMech:lockToScreen(Sprite.ALL)
	self.playerMech.showDebug = true
	--self.camera:setTarget(self.player)
	--self.camera:setDeadzone(128,32)
	GameState:add(self.playerMech)
	
	--Attach gun to mech
	playerGun = Emitter:new(0,0)
	for i=1, 5 do
		local curParticle = Sprite:new(0,0,"images/particles/bullet_orange_16.png")
		curParticle.attackPower = 2
		playerGun:addParticle(curParticle)
		self.playerBullets:add(curParticle)
	end
	playerGun:setSpeed(500)
	playerGun:setAngle(0,1)
	playerGun:lockParent(self.playerMech, false, 107, 16)
	playerGun:setSound(LevelManager:getSound("cannon"))
	playerGun:setCallback(self.playerMech, PlayerMech.fireGun)
	playerGun:start(false, 3, .5, -1)
	playerGun:stop()
	self.emitters:add(playerGun)
	self.playerMech:addWeapon(playerGun, 1)
	
	--Set as player first, then toggle to do camera setup
	self.player = self.playerShip
	GameState:togglePlayerMode("mech")
	
	--Create enemies
	self.enemies = Group:new()
	GameState:add(self.enemies)
	--self.enemies.showDebug = true
	self.enemyBullets = Group:new()
	--Don't add bullets directly to state, will let particle emitters handle them
	self.lastTrigger = 0
	self.stageTriggers = LevelManager:getTriggers(currentLevel)

	--Put particles on top of everything else
	GameState:add(self.emitters)
	
	--Hud
	self.hud = Group:new()
	
	local hpX = 10
	local hpY = 10
	local hpW = 35 * 3
	local hpH = 16
	local hpBack = Sprite:new(hpX+28,hpY+8)

	hpBack:createGraphic(hpW, hpH, {127,127,127}, 255)
	self.hud:add(hpBack)
	self.hpBar = Sprite:new(hpX+28,hpY+8)
	self.hpBar:createGraphic(hpW, hpH, {255,59,0}, 255)
	self.hud:add(self.hpBar)
	local hpOverlay = Sprite:new(hpX, hpY, "images/ui/hud_health.png")
	self.hud:add(hpOverlay)
	
	highScoreText = Text:new(General.screenW, 10, "Score: " .. self.score,"fonts/04b09.ttf", 18)
	highScoreText:setAlign(Text.RIGHT)
	self.hud:add(highScoreText)
	
	self.hud:setEach("scrollFactorX", 0)
	self.hud:setEach("scrollFactorY", 0)
	
	GameState:add(self.hud)
	
	--Do music
	self.bgmMusic = love.audio.newSource(LevelManager:getLevelMusic(1))
    self.bgmMusic:setLooping(true)
	self.bgmMusic:setVolume(.2)
	self.bgmMusic:play()
end

--[[ Spawn a group of enemies past the screen edge
	NumEnemies	Number of enemies to spawn
	SpawnY		Height to spawn enemies at
]]
function GameState:spawnEnemyGroup(NumEnemies, SpawnY)
	local cameraX, cameraY = self.camera:getPosition()
	local spawnY = SpawnY or General.screenH/3
	
	local image, height, width = LevelManager:getEnemy()
	for i=1, NumEnemies or 5 do
		--Calculate location
		local spawnX = cameraX + General.screenW + (i * 128)
		local spawnY = spawnY + 256 * (math.random()-.5)

		--Attempt to recycle an enemy
		local curEnemy = self.enemies:getFirstAvailable(true)
		if curEnemy == nil then
			--None found, need to create a new enemy
			curEnemy = {}
			curEnemy = Enemy:new(spawnX, spawnY)
			curEnemy:loadSpriteSheet(image, height, width)
			curEnemy:setAnimations()
			curEnemy:setPointValue(100)
			curEnemy:setCollisionBox(7, 26, 44, 19)
			curEnemy:lockToScreen(Sprite.UPDOWN)

			--Create enemy gun
			local enemyGun = Emitter:new(spawnX, spawnY)
			for j=1, 2 do
				--Create bullets
				local curBullet = Sprite:new(spawnX, spawnY, LevelManager:getParticle("bullet-red"))
				curBullet.attackPower = 1
				enemyGun:addParticle(curBullet)
				self.enemyBullets:add(curBullet)
			end
			enemyGun:setSpeed(100, 150)
			enemyGun:lockParent(curEnemy, true, 0)
			--enemyGun:lockTarget(self.player)		(Use this to target the player)
			enemyGun:setAngle(180, 0)
			enemyGun:addDelay(2 + math.random() * i)
			enemyGun:start(false, 10, 2, -1)
			--curEnemy:addChild(enemyGun)

			--Thruster particles
			local enemyThruster = Emitter:new(spawnX, spawnY)
			for j=1, 5 do
				local curParticle = Sprite:new(spawnX, spawnY, LevelManager:getParticle("thruster"))
				enemyThruster:addParticle(curParticle)
			end
			enemyThruster:setSpeed(50, 60)
			enemyThruster:setAngle(0, 30)
			enemyThruster:lockParent(curEnemy, true, curEnemy.width-4, curEnemy.height/2 - 3)
			enemyThruster:start(false, .2, 0)

			--Register emitter, so that it will be updated
			self.emitters:add(enemyThruster)
			
			self.emitters:add(enemyGun)
			self.enemies:add(curEnemy)
		else
			--Found an available enemy, respawn it
			curEnemy:respawn(spawnX, spawnY)
		end

	end
end

function GameState:start()
	State.start(self)
	--self.bgmMusic:play()
end
function GameState:stop()
	State.stop(self)
	self.bgmMusic:stop()
end

function GameState:update()
	GameState:checkTriggers()

	--Loop scenery groups
	for k,v in pairs(self.wrappingSprites.members) do
		-- if right side of wrapping sprite goes off left side of screen
		local screenX = v:getScreenX()
		--if (v.x + v.width) < General.camera.x then
		if screenX + v.width < 0 then
			v.x = v.x + Group.getSize(self.wrappingSprites) * v.width
		end
	end
	for k,v in pairs(self.ground.members) do
		-- if right side of wrapping sprite goes off left side of screen
		
		local screenX = v:getScreenX()
		if screenX + v.width < 0 then
			-- hardcoding width because collisionbox needs to be > width
			-- but setCollisionBox sets width
			v.x = v.x + Group.getSize(self.ground) * 256
		end
	end

	State.update(self)
	
	
	General:collide(self.enemies)				--Collide Group with itself
	General:collide(self.player, self.collisionSprite)
	General:collide(self.enemies, self.ground)
	
	--Collisions with custom callback actions
	General:collide(self.player, self.enemyBullets, nil, Sprite.hardCollide)
	General:collide(self.playerBullets, self.enemies, nil, Sprite.hardCollide)
	General:collide(self.player, self.enemies, nil, Sprite.hardCollide)
	General:collide(self.player, self.ground, self.player, self.player.collideGround, true)
	
	self.cameraFocus.y = self.player.y
	
	highScoreText:setLabel("Score: " .. self.score)
end


function GameState:checkTriggers()
	if self.lastTrigger == table.getn(self.stageTriggers) then
		return
	end
	if self.camera.x > self.stageTriggers[self.lastTrigger+1]["distance"] then
		self.lastTrigger = self.lastTrigger + 1
		GameState:executeTrigger(self.stageTriggers[self.lastTrigger])
	end
end

function GameState:executeTrigger(Trigger)
	local triggerType = Trigger["type"]
	if triggerType == "enemy" then
		GameState:spawnEnemyGroup(Trigger["value"])
	elseif triggerType == "waveClear" then
		if GameState:isWaveClear() then
			Timer:new(3, self, GameState.nextStage)
		else
			self.lastTrigger = self.lastTrigger - 1
		end
	end
end

function GameState:isWaveClear()
	clear = true
	for key, enemy in pairs(self.enemies.members) do
		if enemy.exists == true then
			clear = false
		end
	end
	return clear
end

function GameState:draw()
	State.draw(self)
end

function GameState:keypressed(Key)
	if Key == "lshift" then
		self:togglePlayerMode()
	end

	--Temporary until input manager
	self.player:keypressed(Key)
end

function GameState:keyreleased(Key)

	if Key == "escape" then
		General:setState(PauseState,false)
	end

	--Temporary until input manager
	self.player:keyreleased(Key)
end

function GameState:togglePlayerMode()
	local playerMode = self.player.activeMode
	
	if playerMode == "mech" then
		self.playerShip:enterMode(self.playerMech:exitMode())
		self.player = self.playerShip
		self.camera:setTarget(self.cameraFocus)
		self.camera:setDeadzone(0,0,0,0)
		self.cameraFocus.x = .75 * General.screenW + self.camera.x
	elseif playerMode == "ship" then
		self.playerMech:enterMode(self.playerShip:exitMode())
		self.player = self.playerMech
		self.camera:setTarget(self.player)
		self.camera:setDeadzone(General.screenW, 0, -256, 0)
	end
end

function GameState:nextStage()
	Utility:updateHighScores("Player", self.score)
	local currentLevel = General:getCurrentLevel()
	General:setCurrentLevel(currentLevel + 1)
	General:setState(GameLoadState)
end

function GameState:gameOver()
	General:setScore(self.score)
	Utility:updateHighScores("Player", self.score)
	--General:setState(MenuState)
	General:setState(GameEndedState)
end

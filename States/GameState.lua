GameState = {
	ENEMYTYPES = 4,
	BOSSTYPES = 1,
	loaded = false,
	CAMERASCROLLSPEED = 200,
	playerGroundMode = false,
	score = 0,
	lastTrigger = 0,
	curTriggerIndex = 0,
	advanceTriggerDistance = true
}	

GameState.__index = GameState
setmetatable(GameState, State)

function GameState:load()
	State.load(self)

	local currentLevel = General:getCurrentLevel()
	
	self.scripts = Group:new()
	self.scripts.showDebug = true
	GameState:add(self.scripts)

	self.objects = Group:new()

	--Create camera
	self.camera = General:newCamera(0,0)
	self.camera:setBounds(0, -32, General.screenW + 32, General.screenH)
	--GameState:add(self.camera)
	
	self.cameraFocus = Sprite:new(General.screenW/2, General.screenH/2)
	self.cameraFocus.velocityX = self.CAMERASCROLLSPEED
	self.cameraFocus:setVisible(false)
	self.cameraFocus.showDebug = true
	GameState:add(self.cameraFocus)

	--Set up particles
	self.emitters = Group:new()
	self.worldParticles = Group:new()

	--Create background
	self.wrapBg = Group:new()

	local bgLayers = LevelManager:getBgLayers(currentLevel)
	for i=1, table.getn(bgLayers) do
		local layerGroup = Group:new()
		local bgImage = bgLayers[i]["image"]
		local scroll = bgLayers[i]["scrollFactor"]
		local offset = bgLayers[i]["offset"]
		
		local width = love.graphics.newImage(bgImage):getWidth() + offset
		for j=0, math.ceil(General.screenW/width) do
			local spriteBg = Sprite:new(j*width, bgLayers[i]["y"], bgImage)
			spriteBg.scrollFactorX = scroll
			spriteBg.scrollFactorY = scroll
			spriteBg.width = width
			layerGroup:add(spriteBg)
		end
		self.wrapBg:add(layerGroup)
	end
	--error(table.getn(bgLayers))
	--for i=0, 1, 1 do 
	--	local spriteBg = Sprite:new(i * 960, -64, LevelManager:getBgLayers(currentLevel)[1]["image"])
	--	self.wrappingSprites:add(spriteBg)
	--end

	--Create floor
	self.ground = Group:new()
	for i=0, 4 do 
		local floorBlock = Sprite:new(i * 256, General.screenH- 128, LevelManager:getGroundImage(currentLevel))
		floorBlock:setCollisionBox(0,30, 400, 198)
		floorBlock.immovable = true
		self.ground:add(floorBlock)
		--self.wrappingSprites:add(floorBlock)
	end
	--self.wrappingSprites:add(self.ground) (Nested groups not yet fully supported)
	local GROUNDDEPTH = 100
	self.groundCollide = Sprite:new(-32, General.screenH-GROUNDDEPTH)
	self.groundCollide:createGraphic(3200000, GROUNDDEPTH, {255,255,255})
	self.groundCollide.immovable = true
	self.groundCollide.visible = false
	
	GameState:add(self.wrapBg)
	GameState:add(self.ground)
	GameState:add(self.groundCollide)

	self.collisionSprite = Sprite:new(200,200,"images/button_256x64.png")
	self.collisionSprite:setCollisionBox(0,0,256,64)
	self.collisionSprite:lockToScreen(Sprite.ALL)
	self.collisionSprite:setExists(false)
	GameState:add(self.collisionSprite)

	--Create player (flying)
	local image, height, width = LevelManager:getPlayerShip()
	self.playerShip = PlayerShip:new(100, General.screenH-200)
	self.playerShip:loadSpriteSheet(image, height, width)
	self.playerShip:setAnimations()
	self.playerShip:setCollisionBox(46, 34, 91, 20)
	self.playerShip:lockToScreen(Sprite.ALL)
	self.playerShip.showDebug = true
	GameState:add(self.playerShip)
	
	local playerGun = Emitter:new(0,0)
	self.playerBullets = Group:new()
	for i=1, 10 do
		local curParticle = Sprite:new(0,0,LevelManager:getParticle("laser"))
		curParticle.attackPower = .5
		playerGun:addParticle(curParticle)
		self.playerBullets:add(curParticle)
	end
	playerGun:setSpeed(1000)
	playerGun:setAngle(0,0)
	playerGun:lockParent(self.playerShip, false)
	playerGun:setSound(LevelManager:getSound("laser"))
	playerGun:start(false, 1, .12, -1)
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
	
	--Create player Mech
	image, height, width = LevelManager:getPlayerMech()

	self.playerMech = PlayerMech:new(100,General.screenH-100)
	self.playerMech:loadSpriteSheet(image, height, width)
	self.playerMech:setAnimations()
	self.playerMech:setCollisionBox(22,16,PlayerMech.DEFAULTW, PlayerMech.DEFAULTH)
	self.playerMech:lockToScreen(Sprite.ALL)
	self.playerMech.showDebug = true
	--self.camera:setTarget(self.player)
	--self.camera:setDeadzone(128,32)
	GameState:add(self.playerMech)
	
	--Attach gun to mech
	playerGun = Emitter:new(0,0)
	for i=1, 7 do
		local curParticle = Sprite:new(0,0, LevelManager:getParticle("bullet-orange"))
		curParticle.attackPower = 1.5
		playerGun:addParticle(curParticle)
		self.playerBullets:add(curParticle)
	end
	playerGun:setSpeed(500,525)
	playerGun:setAngle(0,1)
	playerGun:lockParent(self.playerMech, false, 107, 16)
	playerGun:setSound(LevelManager:getSound("cannon"))
	playerGun:setCallback(self.playerMech, PlayerMech.fireGun)
	playerGun:start(false, 2, .3, -1)
	playerGun:stop()
	self.emitters:add(playerGun)
	
	local playerCasings = Emitter:new(0,0)
	for i=1,14 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("bullet_casing"), 12, 12)
		curParticle:setCollisionBox(2,2,8,8)
		curParticle:addAnimation("default", {1,2,3,4}, .03, true)
		curParticle:playAnimation("default")
		playerCasings:addParticle(curParticle)
		self.worldParticles:add(curParticle)
	end
	playerCasings:setSpeed(400)
	playerCasings:setAngle(115, 10)
	playerCasings:setGravity(1000)
	playerCasings:setDrag(50)
	playerCasings:lockParent(self.playerMech, false, 30, 20)
	playerCasings:start(false, 1, .3, 1)
	playerCasings:stop()
	self.emitters:add(playerCasings)

	self.playerMech:addWeapon(playerGun, 1, playerCasings)

	
	--Create mech thruster
	local mechThrust_Jet = Emitter:new()
	--Empty
	
	local mechThrust_Smoke = Emitter:new()
	for i=1, 15 do
		local curParticle = Sprite:new(0,0)
		curParticle:loadSpriteSheet(LevelManager:getParticle("smoke"), 32,32)
		curParticle:addAnimation("default", {1,1,1,2,3,4,3,2,1}, .01, false)
		curParticle:playAnimation("default")
		mechThrust_Smoke:addParticle(curParticle)
	end
	mechThrust_Smoke:setSpeed(500,800)
	mechThrust_Smoke:setAngle(245, 20)
	mechThrust_Smoke:setGravity(-4000)
	mechThrust_Smoke:setDrag(10)
	mechThrust_Smoke:lockParent(self.playerMech, false, -26, 24)
	mechThrust_Smoke:start(false, .15, .01, -1)
	mechThrust_Smoke:stop()
	self.emitters:add(mechThrust_Smoke)

	self.playerMech:assignThruster(mechThrust_Jet, mechThrust_Smoke)
	
	
	--Create enemies
	self.enemies = Group:new()
	for i=1, self.ENEMYTYPES do
		self.enemies:add(Group:new())
	end
	for i=1, self.BOSSTYPES do
		self.enemies:add(Group:new())
	end
	self.enemyBullets = Group:new()	--Don't add to state, particle emitters handle bullets
	GameState:add(self.enemies)
	
	--Mark stage triggers
	self.lastTrigger = 0
	--Read triggers
	self.stageTriggers = LevelManager:getTriggers(currentLevel)

	
	--Set up effects
	self.explosion = Effect:new()
	self.explosion:initExplosion()
	GameState:add(self.explosion)
	self.groundParticle = Effect:new()
	self.groundParticle:initGroundParticle(LevelManager:getLevelTheme(currentLevel))
	GameState:add(self.groundParticle)

	--Put particles on top of everything else
	GameState:add(self.emitters)
	
	--Hud
	self.hud = Group:new()
	
	local hudX = 10
	local hudY = 10
	
	--Create hp bar
	local hpX = hudX
	local hpY = hudY
	local hpW = 35 * 3
	local hpH = 16
	local hpBack = Sprite:new(hpX+28,hpY+8)
	hpBack:createGraphic(hpW, hpH, {127,127,127}, 255)
	self.hud:add(hpBack)

	self.hpBar = Sprite:new(hpX+28,hpY+8)
	self.hpBar:loadSpriteSheet("images/ui/hud_healthBar.png", 105, 16)
	self.hpBar:addAnimation("default", {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, .05, true)
	self.hpBar:playAnimation("default")
	--self.hpBar:createGraphic(hpW, hpH, {255,59,0}, 255)
	self.hud:add(self.hpBar)

	self.hpMask = Sprite:new(hudX + hpW +28, hpY + 8)
	self.hpMask:createGraphic(hpW, hpH, {100,100,100}, 255)
	self.hpMask.originX = hpW
	self.hpMask.scaleX = 0
	self.hud:add(self.hpMask)
	local hpOverlay = Sprite:new(hpX, hpY, "images/ui/hud_health.png")
	self.hud:add(hpOverlay)
	
	--Create shield bar
	local shieldY = hudY + hpH*2
	local shieldW = 64
	local shieldH = hpH
	local shieldBack = Sprite:new(hudX+22, shieldY + 8)
	shieldBack:createGraphic(shieldW, shieldH, {127,127,127}, 255)
	self.hud:add(shieldBack)

	self.shieldBar = Sprite:new(hudX+22, shieldY + 8)
	self.shieldBar:loadSpriteSheet("images/ui/hud_shieldBar.png", 64, 16)
	self.shieldBar:addAnimation("default", {15,14,13,12,11,10,9,8,7,6,5,4,3,2,1}, .04, true)
	self.shieldBar:playAnimation("default")
	self.hud:add(self.shieldBar)

	self.shieldMask = Sprite:new(hudX + shieldW +22, shieldY + 8)
	self.shieldMask:createGraphic(shieldW, shieldH, {100,100,100}, 255)
	self.shieldMask.originX = shieldW
	self.shieldMask.scaleX = 0
	self.hud:add(self.shieldMask)
	self.shieldOverlay = Sprite:new(hudX, shieldY, "images/ui/hud_shield.png")
	self.hud:add(self.shieldOverlay)
	
	--Create transform delay bar
	local modeY = shieldY + shieldH*2
	local modeW = 119
	local modeH = 6
	local modeBack = Sprite:new(hpX+2, modeY + 1, "images/ui/hud_transformDelay_bg.png")
	modeBack.scaleY = 6
	self.hud:add(modeBack)
	self.modeMask = Sprite:new(hpX + modeW +2, modeY + 1)
	self.modeMask:createGraphic(modeW, modeH, {100,100,100}, 255)
	self.modeMask.originX = 119
	self.hud:add(self.modeMask)
	local modeOverlay = Sprite:new(hpX, modeY, "images/ui/hud_transformDelay.png")
	self.hud:add(modeOverlay)
	
	--Create high score text
	highScoreText = Text:new(General.screenW, 10, "Score: " .. self.score,"fonts/04b09.ttf", 18)
	highScoreText:setAlign(Text.RIGHT)
	self.hud:add(highScoreText)
	
	self.messageBox = MessageBox:init()
	self.messageBox:genComponents()
	self:addOverlay(self.messageBox)

	
	--Keep all Hud elements from moving
	self.hud:setEach("scrollFactorX", 0)
	self.hud:setEach("scrollFactorY", 0)
	
	GameState:add(self.hud)
	
	--Set player mode, then toggle to do camera setup
	self.player = self.playerShip
	GameState:togglePlayerMode("mech")
	
	--Organize groups
	self.objects:add(self.ground)
	self.objects:add(self.player)
	self.objects:add(self.worldParticles)
	self.objects:add(enemies)
	
	--Do music
	SoundManager:playBgm(LevelManager:getLevelMusic(currentLevel))
end

--[[ Spawn a group of enemies past the screen edge
	NumEnemies	Number of enemies to spawn
	Type		Enemy type to spawn
]]
function GameState:spawnEnemyGroup(NumEnemies, Type)
	local cameraX, cameraY = self.camera:getPosition()
	local spawnY = General.screenH/3

	local enemyClass = nil
	if Type == 1 then
		enemyClass = Enemy1
	elseif Type == 2 then
		enemyClass = Enemy2
	elseif Type == 3 then
		enemyClass = Enemy3
	elseif Type == 4 then
		enemyClass = Enemy4
	elseif Type == -1 then
		enemyClass = Boss1
	end

	--Get image and size
	local image, height, width
	if Type > 0 then
		--Normal enemy
		image, height, width = LevelManager:getEnemy(Type)
	else
		--Boss, so also need to modify Type value
		image, height, width = LevelManager:getBoss(-Type)
		Type = GameState.ENEMYTYPES - Type
	end
	
	for i=1, NumEnemies or 5 do
		--Calculate location
		local spawnX = cameraX + General.screenW + (i * 256)
		--local spawnY = spawnY + 256 * (math.random()-.5)

		--Attempt to recycle an enemy
		local curEnemy = self.enemies.members[Type]:getFirstAvailable(true)
		if curEnemy == nil then
			--None found, need to create a new enemy
			curEnemy = {}
			curEnemy = enemyClass:new(spawnX, 0)
			curEnemy:loadSpriteSheet(image, height, width)
			curEnemy:doConfig()
			
			self.enemies.members[Type]:add(curEnemy)
		end

		--Spawn the enemy at a horizontal distance
		curEnemy:respawn(spawnX)
	end
end

function GameState:start()
	State.start(self)
	--self.bgmMusic:play()
end
function GameState:stop()
	SoundManager:stopBgm()
	State.stop(self)
end

function GameState:update()
	GameState:checkTriggers()

	--Loop scenery groups
	for i=1, self.wrapBg.length do
		curSprite = self.wrapBg.members[i].members[1]
		if curSprite:getScreenX() + curSprite.width < 0 then
			curSprite.x = curSprite.x + self.wrapBg.members[i].length * curSprite.width
			table.remove(self.wrapBg.members[i].members, 1)
			table.insert(self.wrapBg.members[i].members, self.wrapBg.members[i].length, curSprite)
			--curSprite.x = curSprite.x + (math.ceil(General.screenW/curSprite.width)+1) * curSprite.width
		end
	end
	--	for k,v in pairs(self.wrappingSprites.members) do
	--		-- if right side of wrapping sprite goes off left side of screen
	--		local screenX = v:getScreenX()
	--		--if (v.x + v.width) < General.camera.x then
	--		if screenX + v.width < 0 then
	--			v.x = v.x + Group.getSize(self.wrappingSprites) * v.width
	--		end
	--	end
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
	General:collide(self.enemies, self.groundCollide)
	General:collide(self.worldParticles,self.groundCollide)
	
	--Collisions with custom callback actions
	General:collide(self.player, self.enemyBullets, nil, Sprite.hardCollide)
	General:collide(self.playerBullets, self.enemies, nil, Sprite.hardCollide)
	General:collide(self.player, self.enemies, nil, Sprite.hardCollide)
	--General:collide(self.player, self.ground, self.player, self.player.collideGround, true)
	General:collide(self.player, self.groundCollide, self.player, self.player.collideGround, true)
	
	self.cameraFocus.y = self.player.y
	
	highScoreText:setLabel("Score: " .. self.score)
end

local triggerDistance = 0
local storedPlayerX = 0
function GameState:checkTriggers()
	elapsedPlayerX = self.player.x - storedPlayerX
	storedPlayerX = self.player.x
	if self.advanceTriggerDistance then
		triggerDistance = triggerDistance + elapsedPlayerX
	end
	print(triggerDistance)
	if self.lastTrigger == table.getn(self.stageTriggers) then
		return
	end
	if triggerDistance > self.stageTriggers[self.lastTrigger+1]["distance"] then
		self.lastTrigger = self.lastTrigger + 1
		GameState:executeTrigger(self.stageTriggers[self.lastTrigger])
	end
end

function GameState:executeTrigger(Trigger)
	local triggerType = Trigger["type"]
	if triggerType == "enemy" then
		GameState:spawnEnemyGroup(Trigger["value"], Trigger["enemyType"])
	elseif triggerType == "script" then
		self.scripts:add(Script:loadScript(Trigger["value"]))
		self.advanceTriggerDistance = false
	elseif triggerType == "waveClear" then
		if GameState:isWaveClear() then
			self:nextStage()
		else
			self.lastTrigger = self.lastTrigger - 1
		end
	end
end

function GameState:isWaveClear()
	clear = true
	if self.enemies:getFirstUnavailable(true) == nil then
		return true
	else
		return false
	end

	return clear
end

function GameState:draw()
	State.draw(self)
end

function GameState:keypressed(Key)
	if self.messageBox.visible and 
		(Key == "return" or Key == " ") then
		self.messageBox:keypressed()
		return
	end
	if Key == "lshift" then
		self:togglePlayerMode()
	end
	--Temporary until input manager
	self.player:keypressed(Key)
end

function GameState:keyreleased(Key)

	if Key == "escape" then
		General:setState(PauseState,false)
	elseif Key == "end" or Key == "n" then
		self:nextStage()
	end

	--Temporary until input manager
	self.player:keyreleased(Key)
end

function GameState:togglePlayerMode(Force)
	if (Player.lockTransform or not Player.enableControls) and Force ~= true then
		return
	end	
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
	self.player:disableTransform()
	Timer:new(self.player.transformDelay, self.player, Player.enableTransform)
	self.modeMask.scaleX = 1
end

function GameState:nextStage()
	General:getCamera():fade({255,255,255}, .5)
	SoundManager:stopBgm()
	Timer:new(.5, self, self.startNextStage)
end

function GameState:startNextStage()
	local currentLevel = General:getCurrentLevel()
	General:setCurrentLevel(currentLevel + 1)
	General:setState(GameState)
end

function GameState:gameOver()
	local lastScore = General:getScore()
	General:setScore(self.score + lastScore)
	General:setState(NewHighScoreState)
end

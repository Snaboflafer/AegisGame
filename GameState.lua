GameState = {
	CAMERASCROLLSPEED = 200,
	playerGroundMode = false,
	score = 0
}	
GameState.__index = GameState
setmetatable(GameState, State)

function GameState:load()
	State:load()

	isInvincible = false
	--Create camera
	self.camera = General:newCamera(0,0)
	self.camera:setBounds(-64, -32, General.screenW + 32, General.screenH)
	GameState:add(self.camera)
	
	self.cameraFocus = Sprite:new(General.screenW/2, General.screenH/2)
	self.cameraFocus:setVisible(false)
	self.cameraFocus.showDebug = true
	GameState:add(self.cameraFocus)


	self.wrappingSprites = Group:new()

	--Create background
	for i=0, 1, 1 do 
		local spriteBg = Sprite:new(i * 960, -64,
						"images/StealthHawk-Alien-Landscape-33.jpg")
		spriteBg.scrollFactorX = .3
		spriteBg.scrollFactorY = .3
		self.wrappingSprites:add(spriteBg)
	end

	--Create floor
	self.ground = Group:new()
	for i=0, 4, 1 do 
		local floorBlock = Sprite:new(i * 256, General.screenH- 128, "images/floor_snow_1.png")
		floorBlock:setCollisionBox(0,30, 256, 198)
		floorBlock.immovable = true
		self.ground:add(floorBlock)
		--self.wrappingSprites:add(floorBlock)
	end
	--self.wrappingSprites:add(self.ground) (Nested groups not yet fully supported)
	
	GameState:add(self.wrappingSprites)
	GameState:add(self.ground)
		
	--Collision test sprite
	self.collisionSprite = Sprite:new(200,200,"images/button_256x64.png")
	self.collisionSprite:setCollisionBox(0,0,256,64)
	self.collisionSprite:lockToScreen(Sprite.ALL)
	self.collisionSprite:setExists(false)
	GameState:add(self.collisionSprite)


	--Set up effects
	self.effect = Effect:new("images/explosion.png")
	self.effect:initialize("explosion", "images/explosion.png",64,64)
	self.effect:play("explosion",-128,-128)
	GameState:add(self.effect)
	
	--Set up particles
	self.emitters = Group:new()

	
	--Create player (flying)
	self.playerShip = PlayerShip:new(100, 100)
	self.playerShip:loadSpriteSheet("images/sprites/player_ship.png",160,80)
	self.playerShip:setAnimations()
	self.playerShip:setCollisionBox(46, 34, 91, 20)
	self.playerShip:lockToScreen(Sprite.ALL)
	self.playerShip.showDebug = true
	--self.camera:setTarget(self.player)
	--self.camera:setDeadzone(128,32)
	GameState:add(self.playerShip)
	
	local playerGun = Emitter:new(0,0)
	self.playerBullets = Group:new()
	for i=1, 5 do
		local curParticle = Sprite:new(0,0,"images/particles/laser.png")
		playerGun:addParticle(curParticle)
		self.playerBullets:add(curParticle)
	end
	playerGun:setSpeed(1000)
	playerGun:setAngle(0,0)
	--playerGun:lockParent(self.player)
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
			curParticle:loadSpriteSheet("images/particles/player_trail.png", 8,3)
			curParticle:addAnimation("idle", {1,2,3,4}, .08, false)
			curParticle:playAnimation("idle")
			jetTrail:addParticle(curParticle)
		end
		jetTrail:setSpeed(70, 150)
		jetTrail:setAngle(180)
		jetTrail:lockParent(self.playerShip, jetLocations[i][1], jetLocations[i][2])
		jetTrail:start(false, .3, 0)
		self.emitters:add(jetTrail)
	end

	self.fuelTimer = 10
	
	self.playerMech = PlayerMech:new(100,100)
	self.playerMech:loadSpriteSheet("images/sprites/player_mech.png",246,246)
	self.playerMech:setAnimations()
	self.playerMech:setCollisionBox(94, 55, 64, 140)
	self.playerMech:lockToScreen(Sprite.ALL)
	self.playerMech.showDebug = true
	--self.camera:setTarget(self.player)
	--self.camera:setDeadzone(128,32)
	GameState:add(self.playerMech)
	GameState:togglePlayerMode(true)
	
	-- Flag set to false as no enemies are destroyed yet
	enemyDestroyed = false;

	--Create enemies
	self.enemies = Group:new()
	GameState:add(self.enemies)
	--self.enemies.showDebug = true
	self.enemyBullets = Group:new()
	--Don't add bullets directly to state, will let particle emitters handle them


	--Put particles on top of everything else
	GameState:add(self.emitters)

	
	--Hud
	self.hud = Group:new()
	highScoreText = Text:new(General.screenW, 10, "Score: " .. self.score,"fonts/04b09.ttf", 18)
	highScoreText:setAlign(Text.RIGHT)
	self.hud:add(highScoreText)
	

	instructionText = Text:new(General.screenW/2, General.screenH*.5,
		"Space to fire! \n Defeat the empire pawns\n for great justice","fonts/04b09.ttf", 36)
	instructionText:setAlign(Text.CENTER)
	instructionText:setColor(255,200,0,255)
	instructionText:setShadow(200,0,0,255)
	self.instructionTimer = 6

	self.hud:add(instructionText)

	waveText = Text:new(General.screenW/2, General.screenH*.5,
		"End of wave!","fonts/04b09.ttf", 36)
	waveText:setAlign(Text.CENTER)
	waveText:setColor(255,200,0,255)
	waveText:setShadow(200,0,0,255)
	self.waveTimer = 3
	waveText:setVisible(false)

	
	self.hud:add(waveText)
	
	GameState:add(self.hud)
	
	--Do music
	self.bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    self.bgmMusic:setLooping(true)
	self.bgmMusic:setVolume(.2)
	self.bgmMusic:play()
	self.explosion = love.audio.newSource("sounds/explosion.wav")
end

--[[ Spawn a group of enemies past the screen edge
	NumEnemies	Number of enemies to spawn
	SpawnY		Height to spawn enemies at
]]
function GameState:spawnEnemyGroup(NumEnemies, SpawnY)
	local cameraX, cameraY = self.camera:getPosition()
	local spawnY = SpawnY or General.screenH/3
	
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
			curEnemy:loadSpriteSheet("images/enemy_1.png",64,64)
			curEnemy:setAnimations()
			curEnemy:setPointValue(100)
			curEnemy:setCollisionBox(7, 26, 44, 19)
			curEnemy:lockToScreen(Sprite.UPDOWN)

			--Create enemy gun
			local enemyGun = Emitter:new(spawnX, spawnY)
			for j=1, 2 do
				--Create bullets
				local curBullet = Sprite:new(spawnX, spawnY, "images/bullet_2.png")
				enemyGun:addParticle(curBullet)
				self.enemyBullets:add(curBullet)
			end
			enemyGun:setSpeed(100, 150)
			enemyGun:lockParent(curEnemy, 0)
			--enemyGun:lockTarget(self.player)		(Use this to target the player)
			enemyGun:setAngle(180, .1)
			enemyGun:addDelay(2 + math.random() * i)
			enemyGun:start(false, 3, 2, -1)
			--curEnemy:addChild(enemyGun)

			--Thruster particles
			local enemyThruster = Emitter:new(spawnX, spawnY)
			for j=1, 5 do
				local curParticle = Sprite:new(spawnX, spawnY, "images/particles/thruster_small.png")
				enemyThruster:addParticle(curParticle)
			end
			enemyThruster:setSpeed(50, 60)
			enemyThruster:setAngle(0, 30)
			enemyThruster:lockParent(curEnemy, curEnemy.width-4, curEnemy.height/2 - 3)
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

	GameState:generateEnemies()

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
			v.x = v.x + Group.getSize(self.ground) * v.width
		end
	end

	State:update()
	
	
	General:collide(self.enemies)				--Collide Group with itself
	General:collide(self.player, self.collisionSprite)

	for k,bullet in pairs(self.enemyBullets.members) do
		if General:collide(bullet, self.player) then

			-- Destroy animation
			local x, y = bullet:getCenter()
			self.effect:play("explosion", x, y)

			self.explosion:rewind()
			self.explosion:play()

			bullet:setExists(false)
			if isInvincible == false then
				self.fuelTimer = 0
			end
		end
	end

	
	for k,bullet in pairs(self.playerBullets.members) do
		for j,enemy in pairs(self.enemies.members) do
			if General:collide(bullet, enemy) then

				-- Destroy animation
				local x, y = enemy:getCenter()
				self.effect:play("explosion", x, y)

				self.explosion:rewind()
				self.explosion:play()
				self.score = self.score + enemy:getPointValue()

				bullet:setExists(false)
				enemy:setExists(false)
					
			end
		end
	end
	

	--check for player:enemy collisions
	for j,enemy in pairs(self.enemies.members) do
		if General:collide(enemy, self.player) then

			-- Destroy animation
			local x, y = enemy:getCenter()
			self.effect:play("explosion", x, y)

			self.explosion:rewind()
			self.explosion:play()

			enemy:setExists(false)
			if isInvincible == false then	
				self.fuelTimer = 0
			end
		end
	end
	
	--check for player:floor collision
	if General:collide(self.player, self.ground) then
		--self.explosion:rewind()
		--self.explosion:play()
		
		if self.fuelTimer <= 0 then
			GameState:updateHighScores("Player", self.score)
			Data:setScore(self.score)
			local playerX, playerY = self.player:getCenter()
			self.effect:play("explosion", playerX, playerY)

			if math.abs(self.player.velocityY) < 50 then
				General:setState(MenuState)
			end
		end
		
	end

	self.cameraFocus.y = self.player.y
	
	self.instructionTimer = self.instructionTimer - General.elapsed
	self.cameraFocus.velocityX = self.CAMERASCROLLSPEED + self.score/20

	highScoreText:setLabel("Score: " .. self.score)

	if self.instructionTimer <= 0 then
		instructionText:setLabel("")
	end

	if waveText.visible == true then
		self.waveTimer = self.waveTimer - General.elapsed
		if self.waveTimer <= 0 then
			waveText:setVisible(false)
		end
	end
	
	if self.fuelTimer <= 0 then
		self.player.accelerationY = 200
		self.player.dragX = 1
		self.player.enableControls = false
		self.player.bounceFactor = .2
		self.cameraFocus.dragX = .5
    end
end

local currentTrigger = 1
local waveStart = 0
function GameState:generateEnemies()

	local enemyGroups = {
		{1000, "enemy", 3},
		{2000, "enemy", 5},
		{3000, "enemy", 15},
		{4500, "text", 0}
	}

	if currentTrigger <= table.getn(enemyGroups) and self.player.x >= enemyGroups[currentTrigger][1] + waveStart then
		if enemyGroups[currentTrigger][2] == "enemy" then
			GameState:spawnEnemyGroup(enemyGroups[currentTrigger][3])
			currentTrigger = currentTrigger + 1

		elseif enemyGroups[currentTrigger][2] == "text" then
			if GameState:isWaveClear() == true then
				waveText:setVisible(true)
				currentTrigger = 1
				waveStart = self.player.x
				self.waveTimer = 3
			end
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
	elseif Key == 'i' then
		if isInvincible == true then
			isInvincible = false
		else
			isInvincible = true
		end
	end

	--Temporary until input manager
	self.player:keyreleased(Key)
end

function GameState:togglePlayerMode(ForceMode)
	if ForceMode ~= nil then
		self.playerGroundMode = ForceMode
	else
		self.playerGroundMode = not self.playerGroundMode
	end

	if self.playerGroundMode then
		self.playerMech.x = self.playerShip.x
		self.playerMech.y = self.playerShip.y
		self.playerMech.velocityX = self.playerShip.velocityX
		self.playerMech.velocityY = self.playerShip.velocityY
		self.player = self.playerMech
		self.playerShip:setExists(false)
		self.camera:setTarget(self.player)
	else
		self.playerShip.x = self.playerMech.x
		self.playerShip.y = self.playerMech.y
		self.playerShip.velocityX = self.playerMech.velocityX
		self.playerShip.velocityY = self.playerMech.velocityY
		self.player = self.playerShip
		self.playerMech:setExists(false)
		self.camera:setTarget(self.cameraFocus)
		self.cameraFocus.x = .75 * General.screenW + self.camera.x
	end
	self.player:setExists(true)
end

--updates the high scores checking against the score passed
function GameState:updateHighScores(name, score)
   local file = io.open("highScores.txt", "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = ""
    local readName = ""
    local readScore = ""
    local scoresPut = 0
    local newHighScore = false
	--checks each high score against the new score, putting the new score if it exceeds the high score
	repeat
		readName = file:read "*L" --next line with whitespace
	    readScore = file:read "*n" --next number
	    file:read "*L" --kill newline
	    if newHighScore == false and score > readScore then
	    	content = content .. name .. "\n" .. score .. "\n"
	    	scoresPut = scoresPut + 1
	    	newHighScore = true
	    	if scoresPut >= 5 then break end
	    end
	    content = content .. readName .. readScore .. "\n"
	    scoresPut = scoresPut + 1
	until scoresPut >= 5
	file:close()
	content = content:gsub("^%s*(.-)%s*$", "%1") --remove leading and trailing whitespace
	hFile = io.open("highScores.txt", "w+") --write the file.
	hFile:write(content)
	hFile:close()
end

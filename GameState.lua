GameState = {
	CAMERASCROLLSPEED = 200
}	
GameState.__index = GameState
setmetatable(GameState, State)

function GameState:load()
	State:load()
	

	--Create camera
	self.camera = General:newCamera(0,0)
	self.camera:setBounds(-64, -32, General.screenW + 32, General.screenH)
	GameState:add(self.camera)
	
	self.cameraFocus = Sprite:new(General.screenW/2, General.screenH/2)
	self.cameraFocus:setVisible(false)
	self.cameraFocus.showDebug = true

	self.camera:setTarget(self.cameraFocus)
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
	--self.collisionSprite:setExists(false)
	GameState:add(self.collisionSprite)


	--Set up effects
	self.effect = Effect:new("images/explosion.png")
	self.effect:initialize("explosion", "images/explosion.png",64,64)
	self.effect:play("explosion",-128,-128)
	GameState:add(self.effect)
	
	--Set up particles
	self.emitters = Group:new()
	--self.emitters.showDebug = true
	GameState:add(self.emitters)

	--Create player
	self.player = Player:new(100, 100)
	self.player:loadSpriteSheet("images/sprites/player_fly.png",160,80)
	self.player:setAnimations()
	self.player:setCollisionBox(46, 34, 91, 20)
	self.player:lockToScreen(Sprite.ALL)
	self.player.showDebug = true
	--self.camera:setTarget(self.player)
	--self.camera:setDeadzone(128,32)
	GameState:add(self.player)
	
	local jetLocations = {{-15, -16},{-21, 26}}
	for i=1, table.getn(jetLocations) do
			local jetTrail = Emitter:new(spawnX, spawnY)
		for j=1, 20 do
			local curParticle = Sprite:new(spawnX, spawnY)
			curParticle:loadSpriteSheet("images/particles/player_trail.png", 8,3)
			curParticle:addAnimation("idle", {1,2,3,4}, .08, false)
			curParticle:playAnimation("idle")
			jetTrail:addParticle(curParticle)
		end
		jetTrail:setSpeed(70, 150)
		jetTrail:setAngle(180)
		jetTrail:lockParent(self.player, jetLocations[i][1], jetLocations[i][2])
		jetTrail:start(false, .3, 0)
		self.emitters:add(jetTrail)
	end

	self.fuelTimer = 10

	
	-- Flag set to false as no enemies are destroyed yet
	enemyDestroyed = false;

	--Create enemies
	self.enemies = Group:new()
	GameState:add(self.enemies)
	--self.enemies.showDebug = true
	self.enemyBullets = Group:new()
	--Don't add bullets directly to state, will let particle emitters handle them

	--add player bullets
	self.playerBullets = Group:new()
	for i=1,50,1 do
		local bullet = Sprite:new(-20, -20, "images/bullet_1.png")
		self.playerBullets:add(bullet)
	end
	GameState:add(self.playerBullets)

	--Hud
	self.hud = Group:new()
	highScoreText = Text:new(General.screenW, 10, "Score: " .. self.player:getScore(),"fonts/04b09.ttf", 18)
	highScoreText:setAlign(Text.RIGHT)
	self.hud:add(highScoreText)
	
	timeText = Text:new(General.screenW * .5 - 128, 24, "Time: ","fonts/04b09.ttf", 32)
	timeText:setAlign(Text.LEFT)
	self.hud:add(timeText)

	instructionText = Text:new(General.screenW/2, General.screenH*.5,
		"Weapons are offline!\nRam enemy ships before\nyou lose power!","fonts/04b09.ttf", 36)
	instructionText:setAlign(Text.CENTER)
	instructionText:setColor(255,200,0,255)
	instructionText:setShadow(200,0,0,255)
	self.instructionTimer = 6
	self.hud:add(instructionText)
	
	GameState:add(self.hud)
	
	--Do music
	self.bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    self.bgmMusic:setLooping(true)
	self.bgmMusic:setVolume(.2)
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
		end
	end

	--[[
	for k,bullet in pairs(self.playerBullets.members) do
		for j,enemyGroup in pairs(self.enemies) do
			for k,enemy in pairs(self.enemies[j].members) do
				if General:collide(bullet, self.player) then

					-- Destroy animation
					local x, y = bullet:getCenter()
					self.effect:play("explosion", x, y)

					self.explosion:rewind()
					self.explosion:play()
					self.player:updateScore(enemy:getPointValue())

					bullet:setExists(false)
						
					self.fuelTimer = self.fuelTimer + 1
					if not self.player.enableControls and self.fuelTimer > 0 then
						self.player.accelerationY = 0
						self.player.enableControls = true
						self.player.velocityY = 0
						self.cameraFocus.dragX = 0
						self.cameraFocus.velocityX = 300
					end
				end
			end
		end
	end
	--]]

	--check for player:enemy collisions
	for j,enemy in pairs(self.enemies.members) do
		if General:collide(enemy, self.player) then

			-- Destroy animation
			local x, y = enemy:getCenter()
			self.effect:play("explosion", x, y)

			self.explosion:rewind()
			self.explosion:play()
			self.player:updateScore(enemy:getPointValue())

			enemy:setExists(false)
				
			self.fuelTimer = self.fuelTimer + 1
			if not self.player.enableControls and self.fuelTimer > 0 then
				self.player.accelerationY = 0
				self.player.enableControls = true
				self.player.velocityY = 0
				self.cameraFocus.dragX = 0
				self.cameraFocus.velocityX = self.CAMERASCROLLSPEED
			end
		end
	end
	
	--check for player:floor collision
	if General:collide(self.player, self.ground) then
		--self.explosion:rewind()
		self.explosion:play()
		
		if self.fuelTimer <= 0 then
			GameState:updateHighScores("Player", self.player:getScore())
			Data:setScore(self.player:getScore())
			local playerX, playerY = self.player:getCenter()
			self.effect:play("explosion", playerX, playerY)

			if math.abs(self.player.velocityY) < 50 then
				General:setState(MenuState)
			end
		end
		
	end

	self.cameraFocus.y = self.player.y
	
	self.instructionTimer = self.instructionTimer - General.elapsed
	if self.fuelTimer > 0 then
		self.fuelTimer = self.fuelTimer - General.elapsed*.1
		self.cameraFocus.velocityX = self.CAMERASCROLLSPEED + self.player:getScore()/20

	else
		self.fuelTimer = 0
	end

	highScoreText:setLabel("Score: " .. self.player:getScore())
	timeText:setLabel("Time: " .. math.ceil(self.fuelTimer * 10)/10)

	if self.instructionTimer <= 0 then
		instructionText:setLabel("")
	end
	
	if self.fuelTimer <= 0 then
		self.player.accelerationY = 200
		self.player.dragX = 1
		self.player.enableControls = false
		self.player.bounceFactor = .2
		self.cameraFocus.dragX = .5
    end
end
local currentTrigger = 2
function GameState:generateEnemies()
	--currentTrigger = 2
	if State.time > currentTrigger then
		currentTrigger = currentTrigger + 5
		GameState:spawnEnemyGroup(math.random(1,4))
	end
end

function GameState:draw()
	State.draw(self)
end

function GameState:keyreleased(key)
	if key == "escape" then
		General:setState(PauseState,false)
	end
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

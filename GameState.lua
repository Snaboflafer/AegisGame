GameState = {}	
GameState.__index = GameState
setmetatable(GameState, State)

function GameState:load()
	State:load()
	
	self.camera = General:newCamera(0,0)
	self.camera:setBounds(-64, -32, General.screenW + 32, General.screenH)
	GameState:add(self.camera)
	
	self.cameraFocus = Sprite:new(General.screenW/2, General.screenH/2)
	self.cameraFocus:setVisible(false)


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
	
	
	self.collisionSprite = Sprite:new(200,200,"images/button_256x64.png")
	self.collisionSprite:setCollisionBox(0,0,256,64)
	self.collisionSprite:lockToScreen(Sprite.ALL)
	self.collisionSprite:setExists(false)
	GameState:add(self.collisionSprite)


	self.effect = Effect:new("images/explosion.png")
	self.effect:initialize("explosion", "images/explosion.png",64,64)
	self.effect:play("explosion",-128,-128)

	GameState:add(self.effect)

		--Create player
	--player = Player:new(100, 100, "images/ship_fly.png",128,64)
	self.player = Player:new(100, 100)
	self.player:loadSpriteSheet("images/player_ship.png",128,64)
	self.player:setAnimations()
	self.player:setCollisionBox(26, 15, 84, 35)
	self.player:lockToScreen(Sprite.ALL)
	self.camera:setTarget(self.player)
	--self.camera:setDeadzone(128,32)
	GameState:add(self.player)
	self.fuelTimer = 10

	GameState:add(self.cameraFocus)
	self.camera:setTarget(self.cameraFocus)
	
	-- Flag set to false as no enemies are destroyed yet
	enemyDestroyed = false;

	self.enemies = {}
	--GameState:makeNewEnemyGroup(50)

	self.spawnTimer = 1

	--add bullets
	self.bullets = Group:new()
	for i=1,2,1 do
		local curBullet = {}
		curBullet = Bullet:new(-20, -20, "images/bullet_2.png", false)
		self.bullets:add(curBullet)
	end
	GameState:add(self.bullets)

	--Hud
	self.hud = Group:new()	--Group not yet implemented
	highScoreText = Text:new(General.screenW, 10, "Score: " .. self.player:getScore(),"fonts/04b09.ttf", 18)
	highScoreText:setAlign(Text.RIGHT)

	timeText = Text:new(General.screenW * .5 - 128, 24, "Time: ","fonts/04b09.ttf", 32)
	timeText:setAlign(Text.LEFT)


	instructionText = Text:new(General.screenW/2, General.screenH*.5,
		"Weapons are offline!\nRam enemy ships before\nyou lose power!","fonts/04b09.ttf", 36)
	instructionText:setAlign(Text.CENTER)
	instructionText:setColor(255,200,0,255)
	instructionText:setShadow(200,0,0,255)
	self.instructionTimer = 6
	
	GameState:add(highScoreText)
	GameState:add(timeText)
	GameState:add(instructionText)

	--Do music
	self.bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    self.bgmMusic:setLooping(true)
	self.bgmMusic:setVolume(.2)
	self.explosion = love.audio.newSource("sounds/explosion.wav")
end

function GameState:makeNewEnemyGroup(numEnemies,yPosition)
	local cameraX, cameraY = self.camera:getPosition()
	--local xPosition = cameraX + General.screenW
	local yPosition = yPosition or General.screenH/3
	table.insert(self.enemies, Group:new())
		for i=1, numEnemies or 10, 1 do
			local curEnemy = {}
			local xPosition = cameraX + General.screenW
			local randomizedXPosition = xPosition + xPosition*.1*(math.random())
			local randomizedYPosition = yPosition + yPosition*(math.random()-.5)
			curEnemy = enemy:new(randomizedXPosition, randomizedYPosition)
			curEnemy:loadSpriteSheet("images/enemy_1.png",64,64)
			curEnemy:setAnimations()
			curEnemy:setPointValue(100)
			curEnemy:setCollisionBox(7, 26, 44, 19)
			curEnemy:lockToScreen(Sprite.UPDOWN)
			self.enemies[table.getn(self.enemies)]:add(curEnemy)
		end
		GameState:add(self.enemies[table.getn(self.enemies)])
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
	--Spawn players

	GameState:generateEnemies()

	--[[ update bullets
	for k,v in pairs(self.enemies.members) do
		for k1, v1 in pairs(self.bullets.members) do 
			if v1.active == false then
				v1.active = true
				v:shootBullet(v1, self.player.x, self.player.y)
				break
			end
		end
	end

	for k,v in pairs(self.bullets.members) do
		if v.x < -10 or v.y < -10 or v.x > General.screenW + 10 or v.y > General.screenH + 10 then
			v.active = false
		end
	end
	-]]
	
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
		--if (v.x + v.width) < General.camera.x then
		if screenX + v.width < 0 then
			v.x = v.x + Group.getSize(self.ground) * v.width
		end
	end

	State:update()
	
	
	General:collide(self.enemies)				--Collide Group with itself
	General:collide(self.player, self.collisionSprite)
	--check for player:enemy collisions
	for j,enemyGroups in pairs(self.enemies) do
		for k,enemy in pairs(self.enemies[j].members) do
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
					self.cameraFocus.velocityX = 300
				end
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
		self.fuelTimer = self.fuelTimer - General.elapsed
		self.cameraFocus.velocityX = 300 + self.player:getScore()/5

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
	print(State.time)
	if State.time > currentTrigger then
		currentTrigger = currentTrigger + 2
		GameState:makeNewEnemyGroup(10)
	end
end

function GameState:draw()
	State.draw(self)
 	love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor({255, 255, 255, 255})
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

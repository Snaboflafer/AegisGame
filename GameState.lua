GameState = {}	
GameState.__index = GameState
setmetatable(GameState, State)

function GameState:load()
	State:load()
	
	self.camera = General:newCamera(0,0)
	self.camera:setBounds(-32, -32, General.screenW + 32, General.screenH + 32)
	--GameState:add(self.camera)

	--Create floor block
	--May need to change to responsive sizing
	self.floorBlock1 = FloorBlock:new(0, General.screenH-130, "images/floorBlock.png",800,130)
	self.floorBlock1:setCollisionBox(0, 0, self.floorBlock1.width, self.floorBlock1.height)
	self.floorBlock2 = FloorBlock:new(0, General.screenH-130, "images/floorBlock.png",800,130)
	self.floorBlock2:setCollisionBox(0, 0, self.floorBlock2.width, self.floorBlock2.height)

	local spriteBg = sprite:new(0,0 - self.floorBlock1.width,"images/StealthHawk-Alien-Landscape-33.jpg", General.screenW, General.screenH)
	spriteBg.scrollFactorY = .3
	spriteBg.scrollFactorX = .3
	GameState:add(spriteBg)
	--local spriteBg2 = sprite:new(800,0,"images/StealthHawk-Alien-Landscape-33.jpg", General.screenW, General.screenH)
	--GameState:add(spriteBg2)
	GameState:add(self.floorBlock1)

	self.collisionSprite = sprite:new(400,400,"images/button_256x64.png")
	self.collisionSprite:setCollisionBox(1,1,254,62)
	GameState:add(self.collisionSprite)


	self.effect = Effect:new("images/explosion.png")
	self.effect:initialize("explosion", "images/explosion.png",192,192)
	self.effect:play("explosion",0,0)

	GameState:add(self.effect)



	--Create player
	--player = Player:new(100, 100, "images/ship_fly.png",128,64)
	self.player = Player:new(100, 100)
	self.player:loadSpriteSheet("images/player_ship.png",128,64)
	self.player:setAnimations()
	self.player:setCollisionBox(26, 15, 84, 35)
	self.camera:setTarget(self.player)
	self.camera:setDeadzone(128,32)
	GameState:add(self.player)
	self.fuelTimer = 10

	
	-- Flag set to false as no enemies are destroyed yet
	enemyDestroyed = false;
	
	self.enemies = Group:new()
	for i=1,5,1 do
		local curEnemy = {}
		--curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy = enemy:new(General.screenW - 64, (General.screenH - self.floorBlock1.height)* math.random())
		curEnemy:loadSpriteSheet("images/enemy_1.png",64,64)
		curEnemy:setAnimations()
		curEnemy:setPointValue(100)
		curEnemy:setCollisionBox(7, 26, 44, 19)
		curEnemy:lockToScreen()
		self.enemies:add(curEnemy)
	end
	GameState:add(self.enemies)


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
function GameState:start()
	State.start(self)
	self.bgmMusic:play()
end
function GameState:stop()
	State.stop(self)
	self.bgmMusic:stop()
end

function GameState:update()

	State:update()
	General:collide(self.enemies)				--Collide Group with itself
	General:collide(self.player, self.collisionSprite)

	self:checkCollisions()

	self.instructionTimer = self.instructionTimer - General.elapsed
	self.fuelTimer = self.fuelTimer - General.elapsed * .05

	highScoreText:setLabel("Score: " .. self.player:getScore())
	timeText:setLabel("Time: " .. math.ceil(self.fuelTimer * 10)/10)

	if self.instructionTimer <= 0 then
			instructionText:setLabel("")
	end
	
	if self.fuelTimer <= 0 then
		GameState:updateHighScores("Player", self.player:getScore())
    
		GameEndedState.title = "GAME OVER"
		General:setState(GameEndedState, false) 
    
	end
	--]]
end

function GameState:draw()
	State.draw(self)

 	love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor({255, 255, 255, 255})
end

function GameState:checkCollisions()

	--check for player:enemy collisions
	for k,enemy in pairs(self.enemies.members) do
		if General:collide(enemy, self.player) then
			-- Enemy was destroyed

			-- Destroy animation
			self.effect:play("explosion", enemy.x, enemy.y)

			wasDestroyed = true
			self.explosion:rewind()
			self.explosion:play()
			self.player:updateScore(enemy:getPointValue())
			
			--table.remove(self.enemies.members, k)
			enemy.x = General.screenW * math.random()
			enemy.y = (General.screenH - self.floorBlock1.height) * math.random()
			self.fuelTimer = self.fuelTimer + .5
		end
	end

	--check for player:floor collision
	if General:collide(self.floorBlock1, self.player) then
		self.explosion:rewind()
		self.explosion:play()
		General:setState(GameEndedState)
	end

	--check for enemy:floor collision
	for k,enemy in pairs(self.enemies.members) do
		if General:collide(enemy, self.floorBlock1) then
			-- Enemy was destroyed
			--wasDestroyed = true
			--self.explosion:rewind()
			--self.explosion:play()
			--table.remove(self.enemies.members, k)
			--enemy.x = General.screenW * math.random()
			--enemy.y = (General.screenH - self.floorBlock.height) * math.random()
			--self.fuelTimer = self.fuelTimer + .5
		end
	end

end

function GameState:keyreleased(key)
	if key == "escape" then
		General:setState(PauseState,false)
	end
	if key == "up" then
		General:getCamera().y = General:getCamera().target.y - 10
	end
	if key == "down" then
		General:getCamera().y = General:getCamera().target.y + 10
	end
	if key == "left" then
		General:getCamera().x = General:getCamera().target.x - 10
	end
	if key == "right" then
		General:getCamera().x = General:getCamera().target.x + 10
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

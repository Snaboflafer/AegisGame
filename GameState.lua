GameState = {}	
GameState.__index = GameState
setmetatable(GameState, State)

function GameState:load()
	State:load()
	local spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg", General.screenW, General.screenH)
	GameState:add(spriteBg)

	
	--Create player
	--player = Player:new(100, 100, "images/ship_fly.png",128,64)
	self.player = Player:new(100, 100)
	self.player:loadSpriteSheet("images/player_ship.png",128,64)
	self.player:setAnimations()
	self.player:setCollisionBox(26, 15, 84, 35)
	GameState:add(self.player)
	self.fuelTimer = 10

	
	-- Flag set to false as no enemies are destroyed yet
	enemyDestroyed = false;
	
	self.enemies = Group:new()
	for i=1,9,1 do
		local curEnemy = {}
		--curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random())
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
	self.loaded = true
end


function GameState:checkCollisions()

	for k,enemy in pairs(self.enemies.members) do
		if General:collide(enemy, self.player) then
			-- Enemy was destroyed
			wasDestroyed = true
			self.explosion:rewind()
			self.explosion:play()
			self.player:updateScore(enemy:getPointValue())
			
			--table.remove(self.enemies.members, k)
			enemy.x = General.screenW * math.random()
			enemy.y = General.screenH * math.random()

			self.fuelTimer = self.fuelTimer + .5
		end
	end
end

function GameState:start()
	State.time = 0
	self.time = 0
	self.bgmMusic:play()
end

function GameState:stop()
	State.stop(self)
	self.bgmMusic:stop()
end


function GameState:keyreleased(key)
	if key == "escape" then
		General:setState(PauseState,false)
	end
end

function GameState:update()
	State:update()
	self:checkCollisions()

	self.instructionTimer = self.instructionTimer - General.elapsed
	self.fuelTimer = self.fuelTimer - General.elapsed

	highScoreText:setLabel("Score: " .. self.player:getScore())
	timeText:setLabel("Time: " .. math.ceil(self.fuelTimer * 10)/10)

	if self.instructionTimer <= 0 then
			instructionText:setLabel("")
	end
	General:collide(self.enemies)				--Collide Group with itself

	--[[
	if self.fuelTimer <= 0 then
		GameState:updateHighScores("Player", self.player:getScore())

		GameEndedState.title = "GAME OVER"
		General:setState(GameEndedState, false) 

	end
	--]]
end

function GameState:draw()
	State:draw()

 	love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor({255, 255, 255, 255})
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
	

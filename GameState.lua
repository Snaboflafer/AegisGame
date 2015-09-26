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

	--self.sprite1 = Sprite:new(256,256, "images/button_256x64.png")
	--self.sprite1.immovable = true
	--GameState:add(self.sprite1)

	highScoreText = Text:new(General.screenW, 10, "Score: " .. self.player:getScore(),"fonts/04b09.ttf", 18)
	highScoreText:setAlign(Text.RIGHT)

	GameState:add(highScoreText)
	
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

	--Do music
	self.bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    self.bgmMusic:setLooping(true)
	self.bgmMusic:setVolume(.2)
end


function GameState:checkCollisions()

	for k,enemy in pairs(self.enemies.members) do
		if General:collide(enemy, self.player) then
			self.player:updateScore(enemy:getPointValue())
			table.remove(self.enemies.members, k)
		end
	end
end

function GameState:start()
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
	self:checkCollisions()
	-- Fix from global later
	highScoreText:setLabel("Score: " .. self.player:getScore())

	State:update()
	
	--General:collide(self.player, self.sprite1)	--Collide Sprite x Sprite
	--General:collide(self.enemies, self.sprite1)	--Collide Group x Sprite
	General:collide(self.enemies)				--Collide Group with itself
end

function GameState:draw()
	State:draw()

 	love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor({255, 255, 255, 255})
end

--updates the high scores checking against the score passed
function updateHighScores(name, score)
   local file = io.open("highScores.txt", "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = ""
    local restOfFile
    local readName = ""
    local readScore = ""
    local scoresPut = 0
    local newHighScore = false
	--checks each high score against the new score, putting the new score if it exceeds the high score
	repeat
	    content = content .. readName .. "\n" .. readScore .. "\n"
	    scoresPut = scoresPut + 1
	    readName = file:read "*l"
	    readScore = file:read "*n"
	    file:read "*L"
	    if score > readScore and newHighScore == false then
	    	content = content .. name .. "\n" .. score .. "\n"
	    	scoresPut = scoresPut + 1
	    	newHighScore = true
	    end
	until scoresPut > 5
	file:close()
	content = content:gsub("^%s*(.-)%s*$", "%1") --remove leading and trailing whitespace
	hFile = io.open("highScores.txt", "w+") --write the file.
	hFile:write(content)
	hFile:close()
end
	

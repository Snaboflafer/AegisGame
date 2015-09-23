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

	self.sprite1 = Sprite:new(256,256, "images/button_256x64.png")
	self.sprite1.immovable = true
	GameState:add(self.sprite1)

	highScoreText= Text:new(General.screenW, 10, "Score: " .. self.player:getScore(),"fonts/04b09.ttf", 18)
	highScoreText:setAlign(Text.RIGHT)

	GameState:add(highScoreText)
	
	self.enemies = Group:new()
	for i=1,9,1 do
		local curEnemy = {}
		--curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random())
		curEnemy:loadSpriteSheet("images/enemy_1.png",64,64)
		curEnemy:setAnimations()
		curEnemy:setCollisionBox(7, 26, 44, 19)
		curEnemy:lockToScreen()
		self.enemies:add(curEnemy)
	end
	GameState:add(self.enemies)
	
	self.text1 = Text:new(128,128,"SAMPLE TEXT","fonts/04b09.ttf",32)
	self.text1:setAlign(Text.CENTER)
	self.text1:lockToScreen()
	GameState:add(self.text1)
	
	--Do music
	self.bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    self.bgmMusic:setLooping(true)
	self.bgmMusic:setVolume(.2)
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
	self.text1.x, self.text1.y = self.player.x, self.player:getBottom()
	
	State:update()
	
	General:collide(self.player, self.sprite1)	--Collide Sprite x Sprite
	General:collide(self.enemies, self.sprite1)	--Collide Group x Sprite
	General:collide(self.enemies)				--Collide Group with itself
end

function GameState:draw()
	State:draw()

 	love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor({255, 255, 255, 255})
end
	

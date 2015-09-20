GameState = {}	
setmetatable(GameState, State)

function GameState:load()
	General:init()
	General:newCamera(0,0)

	spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg")
	GameState:add(spriteBg)
	
	--Create player
	--player = Player:new(100, 100, "images/ship_fly.png",128,64)
	player = Player:new(100, 100)
	player:loadSpriteSheet("images/ship_fly.png",128,64)
	player:setAnimations()
	player.width = 128
	player.height = 64
	GameState:add(player)

	enemies = Group:new()
	for i=1,9,1 do
		curEnemy = {}
		--curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random())
		curEnemy:loadSpriteSheet("images/enemy_1.png",64,64)
		curEnemy:setAnimations()
		curEnemy.width = 64
		curEnemy.height = 64
		curEnemy:lockToScreen()
		enemies:add(curEnemy)
	end
	GameState:add(enemies)
	
	
	--TESTING
	button1 = Button:new(256,256,"images/button_256x64.png")
	GameState:add(button1)
	
	--Do music
	bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    bgmMusic:setLooping(true)
	bgmMusic:setVolume(0)
	bgmMusic:play()
end

function GameState:keyreleased(key)
    if key == "1" then
        switchTo(HighScoreState)
    end
end

function GameState:draw()
	
	State.draw(self)
	debugStr = ""
	debugStr = debugStr .. "Frame time= " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. "FPS= " .. math.floor(1/General.elapsed) .. "\n"	
	debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	debugStr = debugStr .. "ScreenH = " .. General.screenH .. "\n"
	
	debugStr = debugStr .. "\n"
	debugStr = debugStr .. "player:\n" .. player:getDebug()
	--debugStr = debugStr .. "enemyGroup:\n" .. enemies:toString()
	debugStr = debugStr .. "button1:\n" .. button1:getDebug()

	love.graphics.print(debugStr)
end
	
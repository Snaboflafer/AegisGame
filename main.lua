time = 0

require("General")
require("Utility")
require("State")
sprite = require("Sprite")
player = require("Player")
enemy = require("Enemy")

function love.load()
	General:init()
	General:newCamera(0,0)
	
	gameState = State:new()
	
	spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg")
	gameState:add(spriteBg)
	
	--Create player
	player = Player:new(100, 100, "images/ship_fly.png",128,64)
	gameState:add(player)

	for i=1,9,1 do
		curEnemy = {}
		curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy:lockToScreen()
		gameState:add(curEnemy)
	end
	
	--Do music
	bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    bgmMusic:setLooping(true)
	bgmMusic:setVolume(.2)
	bgmMusic:play()
	
end

function love.update(dt)
	General.elapsed = dt * General.timeScale
	time = time + dt

	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	gameState:update()
	
end

function love.draw()
	gameState:draw()
	
	debugStr = ""
	debugStr = debugStr .. "Frame time= " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. "FPS= " .. math.floor(1/General.elapsed) .. "\n"	
	debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	debugStr = debugStr .. "ScreenH = " .. General.screenH .. "\n"
	debugStr = debugStr .. "\n"
	debugStr = debugStr .. "player:\n" .. player:getDebug()

	--love.graphics.print(debugStr)

end

time = 0

require("General")
require("Utility")
require("State")
require("Group")
sprite = require("Sprite")
player = require("Player")
enemy = require("Enemy")

function love.load()
	General:init()
	General:newCamera(0,0)
	
	gameState = State:new()
	currentState = gameState

	spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg")
	gameState:add(spriteBg)
	
	--Create player
	--player = Player:new(100, 100, "images/ship_fly.png",128,64)
	player = Player:new(100, 100)
	player:loadSpriteSheet("images/ship_fly.png",128,64)
	player:setAnimations()
	player.width = 128
	player.height = 64
	gameState:add(player)

	enemies = Group:new()
	for i=1,9,1 do
		curEnemy = {}
		curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy:lockToScreen()
		enemies:add(curEnemy)
	end
	gameState:add(enemies)
	
	--Do music
	bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    bgmMusic:setLooping(true)
	bgmMusic:setVolume(0)
	bgmMusic:play()
end

function love.update(dt)
	General.elapsed = dt * General.timeScale
	time = time + General.elapsed

	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	currentState:update()
end

function love.draw()
	currentState:draw()
	
	debugStr = ""
	debugStr = debugStr .. "Frame time= " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. "FPS= " .. math.floor(1/General.elapsed) .. "\n"	
	debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	debugStr = debugStr .. "ScreenH = " .. General.screenH .. "\n"
	
	debugStr = debugStr .. "\n"
	debugStr = debugStr .. "player:\n" .. player:getDebug()
	debugStr = debugStr .. "enemyGroup:\n" .. enemies:toString()

	love.graphics.print(debugStr)
end

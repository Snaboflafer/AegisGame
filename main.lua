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
	testState = {}
	
	spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg")

	gameState:add(spriteBg)
	gameState:add(sprite1)
	--table.insert(testState, spriteBg)
	--table.insert(testState, sprite1)
	gameState:add(sprite2)
	
	--player = snbPlayer:new(64, snbG.screenH/2, "blue16.png")
	--table.insert(testState, player)
	player = Player:new(100, 100, "images/ship_fly.png",128,64)
	
	gameState:add(player)

	for i=1,20,1 do
		curEnemy = {}
		curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy:lockToScreen()
		gameState:add(curEnemy)
	end
	
	bgmMusic = love.audio.newSource("sounds/music_Mines_Synth2.ogg")
    bgmMusic:setLooping(true)
	bgmMusic:setVolume(.2)
	bgmMusic:play()
	
end

function love.update(dt)

	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	General.elapsed = dt * General.timeScale
	time = time + General.elapsed
	
	for k,v in ipairs(testState) do
		v:update()
	end
	--sprite1.accelerationY = 50 * math.cos(time)
	
	--testState:update()
	--sprite1:update()
	gameState:update()
	--	for k,v in ipairs(testState) do
	--		v:update()
	--	end
end

function love.draw()
	gameState:draw()
	--	for k,v in ipairs(testState) do
	--		v:draw()
	--	end
	
	debugStr = ""
	debugStr = debugStr .. "Frame time= " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. "FPS= " .. math.floor(1/General.elapsed) .. "\n"	
	debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	debugStr = debugStr .. "ScreenH = " .. General.screenH .. "\n"
	debugStr = debugStr .. "\n"
	debugStr = debugStr .. "player:\n" .. player:getDebug()

	--love.graphics.print(debugStr)

end

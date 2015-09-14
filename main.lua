time = 0

require("General")
require("Utility")
sprite = require("Sprite")
player = require("Player")
enemy = require("Enemy")

function love.load()
	General:init()
	General:newCamera(0,0)
	
	testState = {}
	
	spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg")

	table.insert(testState, spriteBg)
	
	player = Player:new(100, 100, "images/ship_fly.png")
	table.insert(testState, player)
	
	for i=1,9,1 do
		curEnemy = {}
		curEnemy = enemy:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy:lockToScreen()
		table.insert(testState, curEnemy)
	end
	
	bgmMusic = love.audio.newSource("sounds/Locust Toybox - 8-Bit Strawberry.mp3")
    bgmMusic:setLooping(true)
	bgmMusic:setVolume(.5)
	
end

function love.update(dt)

	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	General.elapsed = dt * General.timeScale
	time = time + dt
	
	for k,v in ipairs(testState) do
		v:update()
	end
end

function love.draw()
	for k,v in ipairs(testState) do
		v:draw()
	end
	
	debugStr = ""
	debugStr = debugStr .. "Frame time= " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. "FPS= " .. math.floor(1/General.elapsed) .. "\n"	
	debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	debugStr = debugStr .. "ScreenH = " .. General.screenH .. "\n"
	debugStr = debugStr .. "\n"
	debugStr = debugStr .. "player:\n" .. player:getDebug()

	--love.graphics.print(debugStr)

end

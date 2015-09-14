time = 0

require("General")
sprite = require("Sprite")
--player = require("Player")
enemy = require("Enemy")

function love.load()
	General:init()
	General:newCamera(0,0)
	
	testState = {}
	
	spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg")
	sprite1 = sprite:new(32,256,"images/ship_fly.png",128,128)
	sprite1:lockToScreen()
	sprite1.maxVelocityY = 2
	sprite2 = enemy:new(32, 64,"images/enemy_1.png",64,64)
	sprite2 = sprite:new(32, 64,"images/enemy_1.png",64,64)

	table.insert(testState, spriteBg)
	table.insert(testState, sprite1)
	table.insert(testState, sprite2)
	
	--player = snbPlayer:new(64, snbG.screenH/2, "blue16.png")
	--table.insert(testState, player)
	for i=1,9,1 do
		curEnemy = {}
		curEnemy = sprite:new(General.screenW - 64, General.screenH * math.random(), "images/enemy_1.png",64,64)
		curEnemy:lockToScreen()
		table.insert(testState, curEnemy)
	end
	
	bgmMusic = love.audio.newSource("sounds/Locust Toybox - 8-Bit Strawberry.mp3")
    bgmMusic:setLooping(true)
    --bgmMusic:play()
	bgmMusic:setVolume(.5)
	
	--testState:add(sprite1)
end

function love.update(dt)

	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	General.elapsed = dt * General.timeScale
	time = time + dt
	
	sprite2.velocityX = 5 * math.sin(time)
	sprite2.velocityY = 3 * math.sin(1.23 * time)
	sprite1.velocityY = 5 * math.cos(time)
	
	--testState:update()
	--sprite1:update()
	for k,v in ipairs(testState) do
		v:update()
	end
end

function love.draw()
	for k,v in ipairs(testState) do
		v:draw()
	end
	
	
	debugStr = ""
	debugStr = debugStr .. "Frame time= " .. math.floor(100000 * General.elapsed)/100000 .. "s\n"
	debugStr = debugStr .. "FPS= " .. math.floor(1/General.elapsed) .. "\n"
	
	--debugStr = debugStr .. "snbObject:\n"
	--	for k,v in pairs(snbObject) do
	--		debugStr = debugStr .. "\tk = " .. k .. ", v = " .. tostring(v) .. "\n"
	--	end
	--debugStr = debugStr .. tostring(snbObject) .. "\n"
	
	debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	debugStr = debugStr .. "sprite1:\n" .. sprite1:getDebug()
	debugStr = debugStr .. "sprite2:\n" .. sprite2:getDebug()

	love.graphics.print(debugStr)

end

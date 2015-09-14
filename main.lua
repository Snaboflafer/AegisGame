time = 0

general = require("General")
sprite = require("Sprite")
--player = require("Player")
enemy = require("Enemy")

function love.load()
	general:init()
	general:newCamera(0,0)
	
	testState = {}
	
	spriteBg = sprite:new(0,0,"images/StealthHawk-Alien-Landscape-33.jpg")
	sprite1 = sprite:new(32,256,"images/ship_fly.png",128,128)
	sprite1:lockToScreen()
	sprite2 = enemy:new(32, 64,"images/enemy_1.png",64,64)
	table.insert(testState, spriteBg)
	table.insert(testState, sprite1)
	table.insert(testState, sprite2)
	
	enemy1 = {}
	for i=1,9,1 do
		enemy1[i] = enemy:new(32*i, 64*i,"images/enemy_1.png",64,64)
		enemy1[i].enemyID = i;
		table.insert(testState, enemy1[i])
	end

	--player = snbPlayer:new(64, snbG.screenH/2, "blue16.png")
	--table.insert(testState, player)
	--	for i=1,9,1 do
	--		table.insert(testState, snbSprite:new(snbG.screenW, 128, "images/red16.png"))
	--	end
	
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
	
	general.elapsed = dt
	time = time + dt
	
	sprite1.velocityY = 10 * math.cos(time)
	
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
	debugStr = debugStr .. "Frame time= " .. math.floor(100000 * general.elapsed)/100000 .. "s\n"
	debugStr = debugStr .. "FPS= " .. math.floor(1/general.elapsed) .. "\n"
	
	debugStr = debugStr .. "snbObject:\n"
	--	for k,v in pairs(snbObject) do
	--		debugStr = debugStr .. "\tk = " .. k .. ", v = " .. tostring(v) .. "\n"
	--	end
	--debugStr = debugStr .. tostring(snbObject) .. "\n"
	
	debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	debugStr = debugStr .. "sprite1:\n" .. sprite1:getDebug()
	debugStr = debugStr .. "sprite2:\n" .. sprite2:getDebug()

	love.graphics.print(debugStr)

end

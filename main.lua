time = 0

game = require("Game")
general = require("General")
--snbObject = require("snbObject")
require("Object")
sprite = require("Sprite")
--player = require("Player")
--enemy = require("Enemy")

function love.load()
	curGame = game.new()
	general:init()
	general:newCamera(0,0)
	
	--testState = snbState:new()	--Custom states not implemented yet
	testState = {}
	
	--obj1 = snbObject:new(4,5)
	sprite1 = sprite:new(32,32,"/images/red16.png")
	sprite1.acceleration.x = .01
	sprite2 = sprite:new(32, 64,"images/blue16.png")
	table.insert(testState, sprite1)
	table.insert(testState, sprite2)
	
	--player = snbPlayer:new(64, snbG.screenH/2, "blue16.png")
	--table.insert(testState, player)
	--	for i=1,9,1 do
	--		table.insert(testState, snbSprite:new(snbG.screenW, 128, "images/red16.png"))
	--	end
	
	bgmMusic = love.audio.newSource("sounds/Locust Toybox - 8-Bit Strawberry.mp3")
    bgmMusic:setLooping(true)
    bgmMusic:play()
	bgmMusic:setVolume(.5)
	
	--testState:add(sprite1)
end

function love.update(dt)
	general.elapsed = dt
	time = time + dt
	
	sprite2.velocity.x = 5 * math.sin(time)
	sprite2.velocity.y = 3 * math.sin(1.23 * time)
	
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
	
	debugStr = debugStr .. "snbObject:\n"
	--	for k,v in pairs(snbObject) do
	--		debugStr = debugStr .. "\tk = " .. k .. ", v = " .. tostring(v) .. "\n"
	--	end
	--debugStr = debugStr .. tostring(snbObject) .. "\n"
	
	
	debugStr = debugStr .. "sprite1:\n" .. sprite1:getDebug()
	debugStr = debugStr .. "sprite2:\n" .. sprite2:getDebug()

	love.graphics.print(debugStr)

end
--[[
	Steven Austin sausti12@jhu.edu
	Nathaniel Rhodes nrhodes5@jhu.edu
	Jung Yang jyang99@jhu.edu
	Andrew Shiau ashiau1@jhu.edu
	Team: SOL
]]

time = 0

require("General")
require("Utility")
require("Data")
require("Camera")
require("State")
require("TitleState")
require("HighScoreState")
require("GameState")
require("MenuState")
require("PauseState")
require("GameEndedState")
require("Group")
require("Emitter")
require("Button")
require("Sprite")
require("Bullet")
player = require("Player")
enemy = require("Enemy")
require("Text")
require("Effect")

function love.load()
	General:init()
	--Camera:newCamera(General.screenW/2,General.screenH/2)

	debugText = Text:new(0,0, "fonts/lucon.ttf", 12)
	debugText.visible = false
	
	
	frameTimes = {}	--First value is average
	frameStartTime = os.time()
	
	General:setState(TitleState)
end

function love.update(dt)
	General.elapsed = dt * General.timeScale
	time = time + General.elapsed
	General.activeState:update()

	--Update stored frame times
	if os.time() == frameStartTime then
		table.insert(frameTimes, General.elapsed)
	else
		frameTimes = { (frameTimes[1] + 1/(table.getn(frameTimes)-1)) / 2 }
		frameStartTime = os.time()
	end
	
	--Debug text
	debugStr = ""

	--Game speed info
	debugStr = debugStr .. "Frame time = " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	--debugStr = debugStr .. math.floor(1/General.elapsed) .. "FPS\n"
	debugStr = debugStr .. math.floor(10/frameTimes[1])/10 .. " FPS\n"
	debugStr = debugStr .. "Speed x" .. math.floor(10 * General.timeScale) / 10 .. "\n"

	if TitleState.loaded == true then 
		debugStr = debugStr .. "TitleState (" .. tostring(TitleState) .. ") is loaded\n"
	end
	if GameState.loaded == true then 
		debugStr = debugStr .. "GameState (" .. tostring(GameState) .. ") is loaded\n"
	end
	if PauseState.loaded == true then 
		debugStr = debugStr .. "PauseState (" .. tostring(PauseState) .. ") is loaded\n"
	end
	if MenuState.loaded == true then
		debugStr = debugStr .. "MenuState (" .. tostring(MenuState) .. ") is loaded\n" 
	end
	if HighScoreState.loaded == true then 
		debugStr = debugStr .. "HighScoreState (" .. tostring(HighScoreState) .. ") is loaded\n"
	end
	if GameEndedState.loaded == true then 
		debugStr = debugStr .. "GameEndedState (" .. tostring(GameEndedState) .. ") is loaded\n"
	end
	debugStr = debugStr .. "Registered loaded states:\n"
	if General.loadedStates ~= nil then
		for i=1, General.loadedStates:getSize(), 1 do
			debugStr = debugStr .. "\t(" .. tostring(General.loadedStates.members[i]) .. ")\n"
		end
	end
	debugStr = debugStr .. "Active state:\n\t(" .. tostring(General.activeState) .. ")\n"
	
	
	--Get debug for all members of active state
	for k,v in pairs(General.activeState.members) do
		debugStr = debugStr .. v:getDebug()	
	end

	debugText:setLabel(debugStr)
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	General:draw()
	
	Text.draw(debugText)
end

function love.keyreleased(key)
	General.activeState:keyreleased(key)
	
	if key == "`" then
		debugText.visible = not debugText.visible
	end
end

function love.keypressed(key)
	General.activeState:keypressed(key)
	
	if key == "down" then
		debugText.y = debugText.y - 14
	end
	if key == "up" then
		debugText.y = debugText.y + 14
	end
	if key == "pageup" then
		General.timeScale = General.timeScale - .5
	end
	if key == "pagedown" then
		General.timeScale = General.timeScale + .5
	end
end

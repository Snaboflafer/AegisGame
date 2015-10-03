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
require("Camera")
require("State")
require("TitleState")
require("HighScoreState")
require("GameState")
require("MenuState")
require("PauseState")
require("GameEndedState")
require("Group")
require("Button")
require("Bullet")
sprite = require("Sprite")
player = require("Player")
enemy = require("Enemy")
wrappingSprite  = require("wrappingSprite")
require("Text")
require("Effect")

function love.load()
	General:init()
	--Camera:newCamera(General.screenW/2,General.screenH/2)

	--TitleState:load()
	--MenuState:load()
	--HighScoreState:load()
	--GameState:load()
	
	General:setState(TitleState)
end

function love.update(dt)
	General.elapsed = dt * General.timeScale
	time = time + General.elapsed
	General.activeState:update()
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	General:draw()
	
	debugStr = ""
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
	debugStr = debugStr .. "All loaded states:\n"
	if General.loadedStates ~= nil then
		for i=1, General.loadedStates:getSize(), 1 do
			debugStr = debugStr .. "\t(" .. tostring(General.loadedStates.members[i]) .. ")\n"
		end
	end
	
	debugStr = debugStr .. "Frame time = " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. math.floor(1/General.elapsed) .. "FPS\n"
	
	love.graphics.setFont(love.graphics.newFont("fonts/lucon.ttf", 12))

	for k,v in pairs(General.activeState.members) do
		debugStr = debugStr .. v:getDebug()	
	end

	love.graphics.setColor(255,255,255,255)
	love.graphics.print(debugStr)
end

function love.keyreleased(key)
	General.activeState:keyreleased(key)
end

function love.keypressed(key)
	General.activeState:keypressed(key)
end

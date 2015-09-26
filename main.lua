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
require("State")
require("TitleState")
require("HighScoreState")
require("GameState")
require("MenuState")
require("PauseState")
require("GameEndedState")
require("Group")
require("Button")
sprite = require("Sprite")
player = require("Player")
enemy = require("Enemy")
require("Text")

function love.load()
	General:init()
	General:newCamera(0,0)

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
	General.activeState:draw()
	
	debugStr = ""
	if GameState.loaded == true then debugStr = debugStr .. "GameState loaded\n" end
	if PauseState.loaded == true then debugStr = debugStr .. "PauseState loaded\n" end
	if MenuState.loaded == true then debugStr = debugStr .. "MenuState loaded\n" end
	if HighScoreState.loaded == true then debugStr = debugStr .. "HighScoreState loaded\n" end
	debugStr = debugStr .. "Frame time = " .. math.floor(10000 * General.elapsed)/10000 .. "s\n"
	debugStr = debugStr .. math.floor(1/General.elapsed) .. "FPS\n"
	debugStr = debugStr .. "Active state = " .. tostring(General.activeState)
	--debugStr = debugStr .. "ScreenW = " .. General.screenW .. "\n"
	--debugStr = debugStr .. "ScreenH = " .. General.screenH .. "\n"
	
	love.graphics.setFont(love.graphics.newFont("fonts/segoeui.ttf", 12))

	for k,v in pairs(General.activeState.members) do
		debugStr = debugStr .. v:getDebug()	
	end
	love.graphics.print(debugStr)
end

function love.keyreleased(key)
	General.activeState:keyreleased(key)
end

function love.keypressed(key)
	General.activeState:keypressed(key)
end

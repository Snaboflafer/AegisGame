
JSON = (loadfile "JSON.lua")() -- one-time load of the routines

LevelManager = {
	jsonObject
}


function LevelManager:parseJSON(fileName)
	local contents, size = love.filesystem.read(fileName, size)
	LevelManager.jsonObject = JSON:decode(contents)
end

function LevelManager:getLevelBackground(levelNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["background"]
end

function LevelManager:getLevelFloor(levelNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["floor"]
end

function LevelManager:getLevelMusic(levelNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["music"]
end

function LevelManager:getTriggers(levelNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["triggers"]
end

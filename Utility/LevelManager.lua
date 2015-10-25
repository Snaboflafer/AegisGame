JSON = (loadfile "Utility/JSON.lua")()

LevelManager = {
	jsonObject
}

function LevelManager:parseJSON(fileName)
	local contents, size = love.filesystem.read(fileName, size)
	LevelManager.jsonObject = JSON:decode(contents)
end

function LevelManager:getNumLevels()
	return table.getn(LevelManager.jsonObject["levels"])
end

function LevelManager:getLayerImage(levelNumber, layerNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["layers"][layerNumber]["image"]
end

function LevelManager:getCutScene(levelNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["cut_scene"]
end

function LevelManager:getLevelMusic(levelNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["music"]
end

function LevelManager:getTriggers(levelNumber)
	return LevelManager.jsonObject["levels"][levelNumber]["triggers"]
end

function LevelManager:getPlayerShip()
	local ship = LevelManager.jsonObject["player"]["ship"]
	return ship["image"], ship["height"], ship["width"]
end

function LevelManager:getPlayerMech()
	local mech = LevelManager.jsonObject["player"]["mech"]
	return mech["image"], mech["height"], mech["width"]
end

function LevelManager:getEnemy()
	local enemy = LevelManager.jsonObject["enemy"]
	return enemy["image"], enemy["height"], enemy["width"]
end

function LevelManager:getSound(id)
	return LevelManager.jsonObject["sounds"][id]["src"]
end

function LevelManager:getParticle(id)
	return LevelManager.jsonObject["particles"][id]["src"]
end

function LevelManager:getImage(id)
	return LevelManager.jsonObject["images"][id]["src"]
end
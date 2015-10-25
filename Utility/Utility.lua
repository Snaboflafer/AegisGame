--Utility function class
JSON = (loadfile "Utility/JSON.lua")()

Utility = {

}

--Returns the sign of a number (+/- 1)
function Utility:signOf(Number)
	if (Number >= 0) then
		return 1
	else
		return -1
	end
end

function Utility:mid(Low, High)
	return (High - Low) / 2
end

function Utility:updateHighScores(name, score)
	local contents, size = love.filesystem.read("highScores.json", size)
	local jsonObject = JSON:decode(contents)
	local highScores = jsonObject["highScores"]

	local position = 1
	for k, scoreObject in pairs(highScores) do
		if score > scoreObject["score"] then
			table.remove(highScores, 5)
			table.insert(highScores, position, {["name"]=name, ["score"]=score}) 
			break
		end
		position = position + 1
	end

	jsonObject["highScores"] = highScores

	local outJSON = JSON:encode_pretty(jsonObject)
	love.filesystem.write("highScores.json", outJSON)
end
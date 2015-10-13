--Utility function class

ReadLevel = {
	level = {}
}

function ReadLevel:loadTable(fileName)
	for line in love.filesystem.lines(fileName) do
		local waveTable = {}
		
		for token in string.gmatch(line, '([^,]+)') do
    		table.insert(waveTable, token)
    		print(token)
		end

  		table.insert(ReadLevel["level"], waveTable)
	end
end

function ReadLevel:getLevel()
	return ReadLevel["level"]
end

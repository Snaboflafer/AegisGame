--Utility function class

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

--updates the high scores checking against the score passed
function Utility:updateHighScores(name, score)
    local file = {}
    for line in love.filesystem.lines("highScores.txt") do
    	table.insert(file,line)
    end
    local filePosition = 1
    local content = ""
    local readName = ""
    local readScore = ""
    local scoresPut = 0
    local newHighScore = false
	--checks each high score against the new score, putting the new score if it exceeds the high score
	repeat
		readName = file[filePosition] --next line with whitespace
		filePosition = filePosition + 1
		print("current file position:" .. filePosition)
		print (file[1])
	    readScore = tonumber(file[filePosition])--next number
	    filePosition = filePosition + 1
	    if newHighScore == false and score > readScore then
	    	content = content .. name .. "\n" .. score .. "\n"
	    	scoresPut = scoresPut + 1
	    	newHighScore = true
	    	if scoresPut >= 5 then break end
	    end
	    content = content .. readName .. "\n" .. readScore .. "\n"
	    scoresPut = scoresPut + 1
	until scoresPut >= 5
	content = content:gsub("^%s*(.-)%s*$", "%1") --remove leading and trailing whitespace
	hFile = love.filesystem.write("highScores.txt", content) --write the file.
end
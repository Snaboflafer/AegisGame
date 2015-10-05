--Repository for storing game info

Data = {
	mem1 = nil,
	score = 0
}

function Data:setScore(Value)
	Data.score = Value
end
function Data:getScore()
	return Data.score
end

function Data:setMem1(Value)
	Data.mem1 = Value
end
function Data:getMem1()
	return Data.mem1
end


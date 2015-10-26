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

function Utility:isValidKey(key)
	local validKeys = Utility:Set {
						"a", "b", "c", "d",
						"e", "f", "g", "h", 
						"i", "j", "k", "l",
						"o", "m", "n", "p",
						"q", "r", "s", "t",
						"u", "v", "w", "x", 
						"y", "z", "0", "1",
						"2", "3", "4", "5",
						"6", "7", "8", "9"
					}

	if validKeys[key] == nil then
		return false
	else
		return true
	end
end

function Utility:Set(list)
	local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end
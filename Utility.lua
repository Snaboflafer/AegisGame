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

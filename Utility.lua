--Utility function class

Utility = {

}

--Returns the sign of a number (+/- 1)
function Utility:signOf(number)
	if (number >= 0) then
		return 1
	else
		return -1
	end
end

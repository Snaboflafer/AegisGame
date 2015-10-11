Timer = {
timeRemaining, 
finished
}

function Timer:new()
	s = {}
	setmetatable(s, self)
	self.__index = self
	General.activeState:add(s)
	return s
end

function Time:start(time)
	self.timeRemaining = time;
	self.finished = false;
end

function Timer:stop()
	self.finished = true;
end

function Timer:update()
	if (!self.finished) then 
		self.timeRemaining = self.timeRemaining - General.elapsed
		if self.timeRemaining < 0 then
			self.finished = true
		end
	end
end

return Timer

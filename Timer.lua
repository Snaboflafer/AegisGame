Timer = {
	timeRemaining = 0,
	finished = false,
	callback = nil
}

function Timer:new(Time, Callback)
	s = {}
	setmetatable(s, self)
	self.__index = self
	
	General.activeState:add(s)
	
	s.timeRemaining = Time
	s.finished = false
	s.callback = Callback
	
	return s
end

function Timer:start(Time, Callback)
	self.timeRemaining = Time
	self.finished = false
	self.callback = Callback
	self.exists = true
end

function Timer:stop()
	self.finished = true
end

function Timer:update()
	if not self.finished then 
		self.timeRemaining = self.timeRemaining - General.elapsed
		if self.timeRemaining < 0 then
			--Mark finished, and stop updating
			self.finished = true
			self.exists = false
			
			if self.callback ~= nil then
				--Do callback function if one specified
				self.callback()
			end
		end
	end
end
function Timer:draw()
	--Empty draw, needed for state members
end

return Timer

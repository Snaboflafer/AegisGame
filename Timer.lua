Timer = {
	timeRemaining = 0,
	finished = false,
	callbackObject = nil,
	callbackFunction = nil
}

function Timer:new(Time, CallbackObject, CallbackFunction)
	s = {}
	setmetatable(s, self)
	self.__index = self
	
	General.activeState:add(s)
	
	s.timeRemaining = Time
	s.finished = false
	s.callbackObject = CallbackObject
	s.callbackFunction = CallbackFunction
	
	return s
end

function Timer:start(Time, CallbackObject, CallbackFunction)
	self.timeRemaining = Time
	self.finished = false
	self.callbackObject = CallbackObject
	self.callbackFunction = CallbackFunction
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
			
			if self.callbackFunction ~= nil then
				--Do callback function if one specified
				self.callbackFunction(self.callbackObject)
			end
			
			--Purpose has been fulfilled, time for Seppuku
			self = nil
		end
	end
end
function Timer:draw()
	--Empty draw, needed for state members
end

return Timer

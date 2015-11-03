MessageBox = {
	box = nil,
	text = nil,
	autoAdvance = true,
	autoAdvanceTime = 2
}

function MessageBox:new(X, Y, Label, TypeFace, Size)
	s = Sprite:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.scrollFactorX = 0
	s.scrollFactorY = 0

	s.x = X or 0
	s.y = Y or 0
	
	return s
end

function MessageBox:getDebug()
	debugStr = ""
	debugStr = debugStr .. "MessageBox:\n"
	debugStr = debugStr .. "\t Position = " .. math.floor(self.x) .. ", " .. math.floor(self.y) .. "\n"
	debugStr = debugStr .. "\t Label = \"" .. self.label .. "\"\n"
	debugStr = debugStr .. "\t TypeFace = " .. self.typeFace .. "\n"
	debugStr = debugStr .. "\t Size = " .. self.size .. "\n"

	return debugStr
end
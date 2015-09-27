Text = {
	LEFT = 0,
	CENTER = .5,
	RIGHT = 1,
	label = "",
	typeFace = "fonts/04b09.ttf",
	size = 12,
	font = nil,
	color = {255,255,255,255},
	align = 0,
	shadowColor = {0,0,0,0}
}

function Text:new(X, Y, Label, TypeFace, Size)
	s = Sprite:new(X,Y)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	s.scrollFactorX = 0
	s.scrollFactorY = 0

	s.label = Label or ""
	s.x = X or 0
	s.y = Y or 0
	s.typeFace = TypeFace or "fonts/04b09.ttf"
	s.size = Size
	
	Text.genFont(s)
	--s.font = love.graphics.newFont(s.typeFace, s.size)
	
	return s
end

function Text:setLabel(Label)
	self.label = Label
end
function Text:setColor(R,G,B,A)
	self.color = {R, G, B, A or 255}
end
function Text:setShadow(R,G,B,A)
	self.shadowColor = {R,G,B,A or 255}
end
function Text:setSize(Size)
	self.size = Size
end
function Text:setAlign(Align)
	if not (Align == Text.LEFT or Align == Text.CENTER or Align == Text.RIGHT) then
		return
	end
	self.align = Align
end

function Text:genFont()
	self.font = love.graphics.newFont(self.typeFace, self.size)
end

function Text:draw()
	if not self.visible then
		return
	end

	love.graphics.setFont(self.font)

	if self.shadowColor[4] ~= 0 then
		love.graphics.setColor(self.shadowColor)
		love.graphics.print(
			self.label,
			self.x + self.size/16 - self.align * (self.font:getWidth(self.label)),
			self.y + self.size/16
		)
	end

	love.graphics.setColor(self.color)
	love.graphics.print(
		self.label,
		self.x - self.align * (self.font:getWidth(self.label)),
		self.y
	)
	
end

function Text:getDebug()
	debugStr = ""
	debugStr = debugStr .. "Text:\n"
	debugStr = debugStr .. "\t Position = " .. math.floor(self.x) .. ", " .. math.floor(self.y) .. "\n"
	debugStr = debugStr .. "\t Label = \"" .. self.label .. "\"\n"
	debugStr = debugStr .. "\t TypeFace = " .. self.typeFace .. "\n"
	debugStr = debugStr .. "\t Size = " .. self.size .. "\n"

	return debugStr
end
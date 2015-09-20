Button = {
	isPressed = false,
	lastPressed = false,
	callBack = nil,
	label = ""
}

function Button:new(X,Y, ImageFile, CallBack)
	--s = {}
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	
	s.callBack = CallBack
	--s.image = nil
	
	return s
end


function Button:update()
	Sprite.update(self)
	
	local mouseX,mouseY = love.mouse.getPosition()
	if mouseX > self.x and mouseX < self.x + self.width then
		if mouseY > self.y and mouseY < self.y + self.height then
			if love.mouse.isDown() then
				self.isPressed = true
				self.lastPressed = true
			elseif self.lastPressed then
				callBack()
			end
		end
	end
	--love.event.push('quit')
	

	--self.image = nil
	--self.x = General.screenW * math.random()
end

function Button:draw()
	Sprite.draw(self)
end

Button = {
	isPressed = false,
	callBack = nil
}

function Button:new(X,Y, ImageFile)
	--s = {}
	s = Sprite:new(X,Y,ImageFile)
	setmetatable(s, self)
	setmetatable(self, Sprite)
	self.__index = self
	
	--s.image = nil
	
	return s
end


function Button:update()
	Sprite.update(self)
	--love.event.push('quit')

	--self.image = nil
	self.x = General.screenW * math.random()
end

function Button:draw()
	Sprite.draw(self)
end

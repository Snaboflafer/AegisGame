--Class for camera
Camera = {
	x = 0,
	y = 0,
	zoom = 1,
	bounds = nil,
	target = {
		x = General.screenW/2,
		y = General.screenH/2
	}
}


function Camera:new(X, Y)
	s = {}
	
	setmetatable(s, self)
	self.__index = self
	
	self.x = X
	self.y = Y
	target = {
		self.x + General.screenW/2,
		self.y + General.screenH/2
	}
	
	return s
end

function Camera:update()
	if self.bounds ~= nil then
		if self.x < self.bounds.left then
			self.x = self.bounds.left
		end
		if self.x > self.bounds.right - General.screenW then
			self.x = self.bounds.right - General.screenW
		end
		if self.y < self.bounds.top then
			self.y = self.bounds.top
		end
		if self.y > self.bounds.bottom - General.screenH then
			self.y = self.bounds.bottom - General.screenH
		end
	end
end

function Camera:draw()
	--Empty function, camera object is not drawn
end

function Camera:setBounds(U,D,L,R)
	self.bounds = {up = U or 0, 
				down = D or General.screenH, 
				left = L or 0, 
				right = R or General.screenW}
end

function Camera:getPosition()
	return self.x, self.y
end

function Camera:getDebug()
	debugStr = "Camera:\n" ..
				"\t Position = " .. math.floor(self.x) .. ", " .. math.floor(self.y) .. "\n" ..
				"\t Target = " .. math.floor(self.target.x) .. ", " .. math.floor(self.target.y) .. "\n"
	
	return debugStr
end

return Camera

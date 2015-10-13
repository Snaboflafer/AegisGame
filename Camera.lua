--Class for camera
Camera = {
	x = 0,
	y = 0,
	width = General.screenW,
	height = General.screenH,
	zoom = 1,
	bounds = nil,
	target = nil,
	deadzone = nil
}

function Camera:new(X, Y)
	s = {}
	
	setmetatable(s, self)
	self.__index = self
	
	s.x = X
	s.y = Y
	s.width = General.screenW
	s.height = General.screenH
	s.deadzone = {
		up = 0,
		down = 0,
		left = 0,
		right = 0
	}
	
	return s
end

function Camera:update()
	
	if self.target ~= nil then
		local midX = self.x + self.width/2
		local midY = self.y + self.height/2
		local targetX, targetY = self.target:getCenter()
		
		
		--Move camera if target is outside deadzone
		if targetX < midX - self.deadzone.left then
			self.x = self.x - (midX - targetX)*General.elapsed
		end
		if targetX > midX + self.deadzone.right then
			self.x = self.x  + (targetX - midX)*General.elapsed
		end

		if targetY < midY - self.deadzone.up then
			self.y = self.y - (midY - targetY)*General.elapsed
		end
		if targetY > midY + self.deadzone.down then
			self.y = self.y  + (targetY - midY)*General.elapsed
		end
	end
	
	--Lock to bounds
	if self.bounds ~= nil then
		if self.x < self.bounds.left then
			self.x = self.bounds.left
		end
		if not self.bounds.right == nil and self.x > self.bounds.right - General.screenW then
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
	--Empty function, camera objects are not drawn
end

function Camera:setBounds(L, T, R, B)
	self.bounds = {
		top = T or 0, 
		bottom = B or General.screenH, 
		left = L or 0, 
		right = R
	}
end
function Camera:setDeadzone(L, U, R, D)
	self.deadzone = {
		up = U or 0,
		down = D or 0,
		left = L or 0,
		right = R or 0
	}
end

function Camera:setTarget(TargetObject)
	self.target = TargetObject
end

function Camera:getPosition()
	return self.x, self.y
end

function Camera:destroy()
end
function Camera:getDebug()
	debugStr = "Camera:\n" ..
				"\t Position = " .. math.floor(self.x) .. ", " .. math.floor(self.y) .. "\n" ..
				"\t Target = " .. math.floor(self.target.x) .. ", " .. math.floor(self.target.y) .. "\n"
	
	return debugStr
end

return Camera

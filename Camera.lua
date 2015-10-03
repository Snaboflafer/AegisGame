--Class for camera
Camera = {
	x = 0,
	y = 0,
	width = General.screenW,
	height = General.screenH,
	zoom = 1,
	bounds = nil,
	target = nil,
	deadzone = {
		width = 0,
		height = 0
	}
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
		width = 0,
		height = 0
	}
	
	return s
end

function Camera:update()
	
	if self.target ~= nil then
		local midX = self.x + self.width/2
		local midY = self.y + self.height/2
		local targetX, targetY = self.target:getCenter()
		
		if targetX < midX - self.deadzone.width then
			self.x = self.x - (midX - targetX)*.05
		end
		if targetX > midX + self.deadzone.width then
			self.x = self.x  + (targetX - midX)*.05
		end

		if targetY < midY - self.deadzone.height then
			self.y = self.y - (midY - targetY)*.05
		end
		if targetY > midY + self.deadzone.height then
			self.y = self.y  + (targetY - midY)*.05
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
	self.bounds = {top = T or 0, 
				bottom = B or General.screenH, 
				left = L or 0, 
				right = R}
end
function Camera:setDeadzone(W, H)
	self.deadzone = {
		width = W,
		height = H
	}
end
function Camera:setTarget(TargetObject)
	self.target = TargetObject
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

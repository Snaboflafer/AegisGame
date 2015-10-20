--Class for camera
Camera = {
	x = 0,
	y = 0,
	width = General.screenW,
	height = General.screenH,
	zoom = 1,
	shakeMagnitude = 0,
	shakeDuration = 0,
	fadeColor = nil,
	fadeDuration = 0,
	fadeAlpha = 0,
	bounds = nil,
	target = nil,
	deadzone = nil
}

--[[ Create a new Camera object
	X	Horizontal position
	Y	Vertical position
]]
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
	s.fadeDuration = 0
	s.fadeAlpha = 0
	s.fadeColor = nil
	
	return s
end

--[[ Move camera and apply effects
]]
function Camera:update()
	if self.target ~= nil then
		--Follow target object
		local midX = self.x + self.width/2
		local midY = self.y + self.height/2
		local targetX, targetY = self.target:getCenter()
		
		--Move camera if target is outside deadzone
		if targetX < midX - self.deadzone.left then
			self.x = self.x - (midX - self.deadzone.left - targetX)*General.elapsed
		end
		if targetX > midX + self.deadzone.right then
			self.x = self.x  + (targetX - midX - self.deadzone.right)*General.elapsed
		end

		if targetY < midY - self.deadzone.up then
			self.y = self.y - (midY - targetY)*General.elapsed
		end
		if targetY > midY + self.deadzone.down then
			self.y = self.y  + (targetY - midY)*General.elapsed
		end
	end
	
	if self.shakeDuration > 0 then
		--Apply screen shake
		self.shakeDuration = self.shakeDuration - General.elapsed
		self.x = self.x + 2 * self.shakeMagnitude * self.width * (math.random() - .5)
		self.y = self.y + 2 * self.shakeMagnitude * self.height * (math.random() - .5)
	end
	
	local fadeAlpha = self.fadeAlpha
	if fadeAlpha > 0 and fadeAlpha < 255 then
		fadeAlpha = fadeAlpha + 255 * General.elapsed / self.fadeDuration
		if fadeAlpha > 255 then
			fadeAlpha = 255
		end
		self.fadeAlpha = fadeAlpha
	end
	
	--Prevent camera from moving past bounds
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
function Camera:drawEffects()
	if self.fadeAlpha > 0 then
		local fadeColor = self.fadeColor
		love.graphics.setColor(fadeColor[1], fadeColor[2], fadeColor[3], self.fadeAlpha)
		love.graphics.rectangle(
			"fill",
			0,
			0,
			General.screenW,
			General.screenH
		)
	end
end

--[[ Shake the screen
	Magnitude	Percentage of screen to move in any direction
	Duration	Time shake should last
]]
function Camera:screenShake(Magnitude, Duration)
	self.shakeMagnitude = Magnitude or .1
	self.shakeDuration = Duration or .5
end

function Camera:fade(FadeColor, FadeDuration)
	self.fadeColor = FadeColor
	self.fadeDuration = FadeDuration
	self.fadeAlpha = 0.001
end

--[[ Prevent camera from scrolling past certain points
	L	Leftmost bound
	T	Topmost bound
	R	(Optional) Rightmost bound
	B	Bottommost bound
]]
function Camera:setBounds(L, T, R, B)
	self.bounds = {
		top = T or 0, 
		bottom = B or General.screenH, 
		left = L or 0, 
		right = R
	}
end
--[[ Set the deadzone around the center. Camera scrolls if
		its target object leaves this area.
	L	Distance to left of center
	U	Distance above center
	R	Distance to right of center
	D	Distance below center
]]
function Camera:setDeadzone(L, U, R, D)
	self.deadzone = {
		up = U or 0,
		down = D or 0,
		left = L or 0,
		right = R or 0
	}
end

--[[ Set a target object for camera to follow
	TargetObject	Sprite object to follow
]]
function Camera:setTarget(TargetObject)
	self.target = TargetObject
end

--[[ Returns X,Y position
]]
function Camera:getPosition()
	return self.x, self.y
end

function Camera:destroy()
end
function Camera:getType()
	return "Camera"
end
function Camera:getDebug()
	debugStr = "Camera:\n" ..
				"\t Position = " .. math.floor(self.x) .. ", " .. math.floor(self.y) .. "\n" ..
				"\t Target = " .. math.floor(self.target.x) .. ", " .. math.floor(self.target.y) .. "\n"
	
	return debugStr
end

return Camera

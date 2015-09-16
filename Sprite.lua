--Base class for Sprites. Can create instances, or be extended.

--Default prototype values
Sprite = {
	x = 0,	--Position
	y = 0,
	width = 0,	--Size for collisions
	height = 0,
	velocityX = 0,	--Movement velocity, measured in px/second
	velocityY = 0,
	accelerationX = 0,	--Acceleration, measured in px/second/second
	accelerationY = 0,
	maxVelocityX = -1,	--Maximum speed. Negative values to disable.
	maxVelocityY = -1,
	dragX = 0,	--Drag when no acceleration active
	dragY = 0,
	rotation = 0,	--Rotation of sprite, in radians
	originX = 0,	--Origin for rotation
	originY = 0,	
	offsetX = 0,	--Offset from top left of sprite to collision start
	offsetY = 0,
	scaleX = 1,		--Size multiplier
	scaleY = 1,
	imageFile = "[NO IMAGE]",	--Filename for image
	image = love.graphics.newImage("/images/img_blank.png"), --Image of sprite
	lockToScreen = false,	--Set to true to prevent sprite from moving offscreen
	animated = false,
	animations = {},	--List of animations registered for sprite
	curAnim = nil,		--Table for current animation
	curAnimFrame = 1,	--Frame index for the currently playing animation
	curImageIndex = 1,	--Index for the current current graphic in the image file
	animTimer = 0,		--Timer measuring between animation frames
	animFinished = false,	--Whether the current animation has finished
	curFrameImage = nil,
	touchingU = false,
	touchingD = false,
	touchingL = false,
	touchingR = false
}

-- new function based on http://www.lua.org/pil/16.1.html
function Sprite:new(X,Y, ImageFile, Width, Height)
	s = {}
	setmetatable(s, self)
	self.__index = self

	s.x = X
	s.y = Y
	s.width = Width or 0
	s.height = Height or 0
	if (ImageFile ~= nil) then
		s.imageFile = ImageFile
		s.image = love.graphics.newImage(s.imageFile)
	end
	animations = {}
	return s
end

-- updates velocity and position of sprite
function Sprite:update()
	if self.accelerationX == 0 then
		self.velocityX = self.velocityX - self.dragX*Utility:signOf(self.velocityX)
	else
		self.velocityX = self.velocityX + self.accelerationX*General.elapsed
	end
	if (self.maxVelocityX >= 0) and (math.abs(self.velocityX) > self.maxVelocityX) then
		self.velocityX = self.maxVelocityX * Utility:signOf(self.velocityX)
	end

	if self.accelerationY == 0 then
		self.velocityY = self.velocityY - self.dragY*Utility:signOf(self.velocityY)
	else
		self.velocityY = self.velocityY + self.accelerationY*General.elapsed
	end
	if (self.maxVelocityY >= 0) and (math.abs(self.velocityY) > self.maxVelocityY) then
		self.velocityY = self.maxVelocityY * Utility:signOf(self.velocityY)
	end
	
	self.x = self.x + self.velocityX*General.elapsed
	self.y = self.y + self.velocityY*General.elapsed
	if (lockToScreen) then
		touchingU = false
		touchingD = false
		touchingL = false
		touchingR = false
		
		if self.y < 0 then
			self.y = 0
			touchingU = true
		elseif self.y + self.height > General.screenH then
			self.y = General.screenH - self.height
			touchingD = true
		end
		if self.x < 0 then
			self.x = 0
			touchingL = true
		elseif self.x + self.width > General.screenW then
			self.x = General.screenW - self.width
			touchingR = true
		end
	end

	if (self.animated) then
		self:updateAnimation()
	end
end

function updateAnimation()
	if not self.animated or curAnim == nil then
		return
	end
	
	if (curAnim.loop or not animFinished) then
		animTimer = animTimer + General.elapsed
		if animTimer >= frameTime then
			--Timer reached time for animation frame, reset
			animTimer = 0
			
			if curAnimFrame == table.getn(curAnim.frames) then
				--Last frame of animation
				if curAnim.loop then
					--Restart if looping
					curAnimFrame = 1
				end
				animFinished = true
			else
				--Go to next frame
				curAnimFrame = curAnimFrame + 1
			end
			
			--Set the actual image index for the sheet
			curImageIndex = curAnim.frames[curAnimFrame]
		end
	end
end

function Sprite:addAnimation(AName, Frames, FrameTime, Loop)
	--table.insert(self.animations, {AName, Frames, Speed})
	animations[AName] = {}
	animations[AName] = {name = AName, frames = Frames, frameTime = FrameTime, loop = Loop}
end
function Sprite:playAnimation(AName,Restart)
	if not Restart and (curAnim ~= nil) and (AName == curAnim.name) and not animFinished then
		--Same as current animation, and neither forced restart or finished, so cancel
		return
	end
	if (animations[AName] == nil) then
		--Animation does not exist
		return
	end
	curAnim = animations[AName]
	curAnimFrame = 1
	animTimer = 0
end
function Sprite:genImageFrame()
	--(calcFrame)
	--Generate an image using the spritesheet (TODO)
end

-- draws sprite
function Sprite:draw()
	love.graphics.draw(
		self.image,
		self.x,
		self.y,
		self.rotation,
		self.scaleX, self.scaleY,
		self.offsetX, self.offsetY
	)
end

function Sprite:lockToScreen(value)
	lockToScreen = value or true
end

function Sprite:getType()
	return "Sprite"
end
	
function Sprite:getDebug()
	debugStr = ""
	debugStr = debugStr .. "\t Type = " .. self:getType() .. "\n"
	debugStr = debugStr .. "\t Image = " .. self.imageFile .. "\n"
	debugStr = debugStr .. "\t x = " .. math.floor(self.x) .. "\n"
	debugStr = debugStr .. "\t y = " .. math.floor(self.y) .. "\n"
	debugStr = debugStr .. "\t width = " .. self.width .. ", height = " .. self.height .. "\n"
	debugStr = debugStr .. "\t velocity = " .. math.floor(10 * self.velocityX)/10 .. ", " .. math.floor(10 * self.velocityY)/10 .. "\n"
	debugStr = debugStr .. "\t acceleration = " .. math.floor(10 * self.accelerationX)/10 .. ", " .. math.floor(10 * self.accelerationY)/10 .. "\n"
	return debugStr
end

return Sprite

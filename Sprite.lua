--Base class for Sprites. Can create instances, or be extended.

--Default prototype values
Sprite = {
	VELOCITY_THRESHOLD = 1,
	x = 0,	--Position
	y = 0,
	width = 32,	--Size for collisions
	height = 32,
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
	scrollFactorX = 1,
	scrollFactorY = 1,
	imageFile = "[NO IMAGE]",	--Filename for image
	image = love.graphics.newImage("/images/err_noImage.png"), --Image of sprite
	lockToScreen = false,	--Set to true to prevent sprite from moving offscreen
	visible = true,
	animated = false,
	animations = {},	--List of animations registered for sprite
	curAnim = nil,		--Table for current animation
	curAnimFrame = 1,	--Frame index for the currently playing animation
	curImageQuad = 1,	--Index for the current current graphic in the image file
	animTimer = 0,		--Timer measuring between animation frames
	animFinished = false,	--Whether the current animation has finished
	curFrameImage = nil,
	quadFrameCount = 1,
	imageQuads = {},
	touchingU = false,
	touchingD = false,
	touchingL = false,
	touchingR = false,
	immovable = false,
	bounceFactor = 0,
	alive = false,
	visible = false,
	active = false
}

--[[Create a new sprite
	X		Horizontal initial position
	Y		Vertical initial position
	ImageFile	(Optional) Specify a non-animated image file
	Width	(Optional) Horizontal collision size of sprite
	Height	(Optional) Vertical collision size of sprite
 new function based on http://www.lua.org/pil/16.1.html
--]]
function Sprite:new(X,Y, ImageFile, Width, Height)
	s = {}
	setmetatable(s, self)
	self.__index = self

	
	s.x = X
	s.y = Y
	if (ImageFile ~= nil) then
		s.imageFile = ImageFile
		s.image = love.graphics.newImage(s.imageFile)
	end
	s.width = Width or s.image:getWidth()
	s.height = Height s.image:getHeight()

	s.animations = {}
	s.imageQuads = {}
	
	s.alive = true
	s.visible = true
	s.active = true
	
	return s
end

--[[Load an animated sprite sheet
	ImageFile	Filename for sheet to load
	Width		Pixel width of each frame
	Height		Pixel height of each frame
--]]
function Sprite:loadSpriteSheet(ImageFile, Width, Height)
	--Load image
	self.imageFile = ImageFile
	self.image = love.graphics.newImage(self.imageFile)
	self.animated = true

	--Calculate frames per row/column, and set total
	local hIndices = self.image:getWidth()/Width
	local vIndices = self.image:getHeight()/Height
	self.quadFrameCount = hIndices * vIndices
	
	--Add all frames to imageQuads
	--Frames are indexed by row, then by column, starting at 1,1
	for i=0, vIndices-1, 1 do
		for j=0, hIndices-1, 1 do
			table.insert(self.imageQuads,
				love.graphics.newQuad(j * Width, i * Height,
									Width, Height,
									self.image:getDimensions())
			)
		end
	end
end

function Sprite:destroy()
	for k, v in ipairs(self) do
		self[k] = nil
	end
	self = nil
end
--[[Reset image to default
--]]
function Sprite:resetImage()
	self.imageFile = nil
	self.image = nil
	self.animated = false
	self.width = nil
	self.height = nil
end

function Sprite:setCollisionBox(X, Y, W, H)
	self.offsetX = X
	self.offsetY = Y
	self.width = W
	self.height = H
end

-- updates velocity and position of sprite
function Sprite:update()
	if not self.active then
		return
	end
	
	--Apply either drag or acceleration to velocity
	if self.accelerationX == 0 then
		self.velocityX = self.velocityX - self.dragX * Utility:signOf(self.velocityX)
	else
		self.velocityX = self.velocityX + self.accelerationX * General.elapsed
	end
	--Limit velocity to maximum
	if (self.maxVelocityX >= 0) and (math.abs(self.velocityX) > self.maxVelocityX) then
		self.velocityX = self.maxVelocityX * Utility:signOf(self.velocityX)
	end

	--Apply either drag or acceleration to velocity
	if self.accelerationY == 0 then
		self.velocityY = self.velocityY - self.dragY * Utility:signOf(self.velocityY)
	else
		self.velocityY = self.velocityY + self.accelerationY * General.elapsed
	end
	--Limit velocity to maximum
	if (self.maxVelocityY >= 0) and (math.abs(self.velocityY) > self.maxVelocityY) then
		self.velocityY = self.maxVelocityY * Utility:signOf(self.velocityY)
	end
	
	if (math.abs(self.velocityX) < Sprite.VELOCITY_THRESHOLD) then
		self.velocityX = 0
	end
	if (math.abs(self.velocityX) < Sprite.VELOCITY_THRESHOLD) then
		self.velocityX = 0
	end

	
	--Apply velocity to position
	self.x = self.x + self.velocityX * General.elapsed
	self.y = self.y + self.velocityY * General.elapsed
	
	--Temporary screen bounding collisions
	if (self.lockToScreen) then
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

	--Update animations
	if (self.animated) then
		self:updateAnimation()
	end
end
--[[Determine the current frame for an animated sprite
--]]
function Sprite:updateAnimation()
	if (not self.animated) or (self.curAnim == nil) then
		--Cancel if not animating
		return
	end
	
	--Update if looping or animation has not yet finished
	if (self.curAnim.loop or not self.animFinished) then
		--Update timer
		self.animTimer = self.animTimer - General.elapsed
		
		if self.animTimer <= 0 then
			--Timer reached max time for frame, reset
			self.animTimer = self.curAnim.frameTime
			
			if self.curAnimFrame == table.getn(self.curAnim.frames) then
				--Last frame of animation
				
				if self.curAnim.loop then
					--Restart if looping
					self.curAnimFrame = 1
				end
				--Animation has completed once, mark as finished
				self.animFinished = true
			else
				--Not yet finished, go to next frame
				self.curAnimFrame = self.curAnimFrame + 1
			end
			
			--Set the quad index for this frame
			self.curImageQuad = self.curAnim.frames[self.curAnimFrame]
		end
	end
end

--[[Add an animation to the sprite
	AName	Name of the animation
	Frames	Table containing the ordered list of frames to be used
	FrameTime	Seconds each frame lasts
	Loop	True or False to have animation repeat when finished
--]]
function Sprite:`imation(AName, Frames, FrameTime, Loop)
	--Check that frames are valid
	for i=1, table.getn(Frames), 1 do
		if Frames[i] > self.quadFrameCount then
			self:resetImage()
			self.imageFile = "[ERROR: Animation \"" .. AName .. "\" contains invalid frame index " .. Frames[i] .. "]"
			self.image = love.graphics.newImage("images/err_noAnim.png")
			return
		end
	end

	self.animations[AName] = {name = AName,
							frames = Frames or {1},
							frameTime = FrameTime or 0,
							loop = Loop or false}
end
--[[Start an animation
	AName	Name of animation to play
	Restart	Force animation to restart from beginning
--]]
function Sprite:playAnimation(AName,Restart)
	if self.curAnim ~= nil then
		--Cancel if trying to play the active animation, but neither forced restart nor finished
		if not Restart and (AName == self.curAnim.name) and not self.animFinished then
			return
		end
	
		--Cancel if trying to replay current non-looping animation
		if AName == self.curAnim.name and self.animFinished and not self.curAnim.loop then
			return
		end
	end
	--Check that animation exists
	if (self.animations[AName] == nil) then
		self:resetImage()
		self.imageFile = "[ERROR: Animation \"" .. AName .. "\" not defined]"
		self.image = love.graphics.newImage("images/err_noAnim.png")
		return
	end
	
	--Start animation
	self.curAnim = self.animations[AName]
	self.curAnimFrame = 1
	self.animTimer = self.curAnim.frameTime
	self.animFinished = false
end

--[[Draw sprite to screen
--]]
function Sprite:draw()
	if not self.visible then
		return
	end
	
	local camera = General:getCamera()
	
	if self.animated then
		love.graphics.draw(
			self.image, self.imageQuads[self.curAnim.frames[self.curAnimFrame]],
			self.x - (camera.x * self.scrollFactorX),
			self.y - (camera.y * self.scrollFactorY),
			self.rotation,
			self.scaleX, self.scaleY,
			self.offsetX, self.offsetY
		)
	else
		love.graphics.draw(
			self.image,
			self.x - (camera.x * self.scrollFactorX),
			self.y - (camera.y * self.scrollFactorY),
			self.rotation,
			self.scaleX, self.scaleY,
			self.offsetX, self.offsetY
		)
	end
end

--[[Prevent sprite from moving offscreen during update()
--]]
function Sprite:lockToScreen(value)
	self.lockToScreen = value or true
end

function Sprite:getLeft()
	return self.x + self.offsetX
end
function Sprite:getRight()
	return self.x + self.offsetX + self.width
end
function Sprite:getTop()
	return self.y + self.offsetY
end
function Sprite:getBottom()
	return self.y + self.offsetY + self.height
end
function Sprite:getCenter()
	return self.x + self.offsetX + self.width/2, self.y + self.offsetY + self.height/2
end
	
function Sprite:getType()
	return "Sprite"
end

function Sprite:getDebug()
	debugStr = ""
	debugStr = debugStr .. "Sprite (" .. self:getType() .. "):\n"
	debugStr = debugStr .. "\t Image = " .. self.imageFile .. "\n"
	debugStr = debugStr .. "\t Position = " .. math.floor(self.x) .. ", " .. math.floor(self.y) .. "\n"
	debugStr = debugStr .. "\t Size = " .. self.width .. ", " .. self.height .. "\n"
	debugStr = debugStr .. "\t velocity = " .. math.floor(10 * self.velocityX)/10 .. ", " .. math.floor(10 * self.velocityY)/10 .. "\n"
	debugStr = debugStr .. "\t acceleration = " .. math.floor(10 * self.accelerationX)/10 .. ", " .. math.floor(10 * self.accelerationY)/10 .. "\n"
	if self.animated then
		debugStr = debugStr .. "\t Anim Quad Index = " .. self.curAnim.frames[self.curAnimFrame] .. "\n"
		debugStr = debugStr .. "\t Anim name = " .. self.curAnim.name .. "\n"
	end
	return debugStr
end

return Sprite

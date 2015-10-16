--Base class for Sprites. Can create instances, or be extended.

--Default prototype values
Sprite = {
	VELOCITY_THRESHOLD = 1,
	NONE = 0,
	UP = 1,
	DOWN = 2,
	LEFT = 4,
	RIGHT = 8,
	UPDOWN = 3,
	SIDES = 12,
	ALL = 15,
	color = nil,
	alpha = 255,
	touching = 0,
	touchingPrev = 0,
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
	image = nil, --Image of sprite
	lockSides = 0,	--Set to true to prevent sprite from moving offscreen
	animated = false,
	animations = {},	--List of animations registered for sprite
	curAnim = nil,		--Table for current animation
	curAnimFrame = 1,	--Frame index for the currently playing animation
	curImageQuad = 1,	--Index for the current current graphic in the image file
	animTimer = 0,		--Timer measuring between animation frames
	animFinished = false,	--Whether the current animation has finished
	animMustFinish = false,	--Whether an animation must finish before another can be played
	curFrameImage = nil,
	quadFrameCount = 1,
	imageQuads = {},
	touchingU = false,
	touchingD = false,
	touchingL = false,
	touchingR = false,
	immovable = false,	--Object cannot be pushed by objects during collision
	massless = false,	--Object won't push objects during collision
	bounceFactor = 0,	--Percentage of speed retained after collision
	exists = true,		--Whether the sprite has any calls done on it
	active = true,		--Whether the sprite should update
	visible = true,		--Whether the sprite should draw
	solid = true,		--Whether the sprite responds to collisions
	alive = true,
	lifetime = 0,
	health = 1,
	maxhealth = 1,
	attackPower = 0,
	showDebug = false,
	last = nil,
	flickerDuration = 0
}

function Sprite:setActive(Active)
	self.active = Active
end
function Sprite:setExists(Exists)
	self.exists = Exists
end
function Sprite:setSolid(Solid)
	self.solid = Solid
end
function Sprite:setVisible(Visible)
	self.visible = Visible
end

function Sprite:setPosition(X, Y)
	self.x = X
	self.y = Y
end

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
		s.width = Width or s.image:getWidth()
		s.height = Height s.image:getHeight()
	end
	
	s.color = {255,255,255}
	s.alpha = 255
	
	s.touching = Sprite.NONE
	s.touchingPrev = Sprite.NONE

	s.animations = {}
	s.imageQuads = {}
	
	s.alive = true
	s.visible = true
	s.active = true
	
	s.last = {
		x = X,
		y = Y
	}
	
	return s
end

function Sprite:loadSpriteSheet(ImageFile, Width, Height)
	--Load image
	self.imageFile = ImageFile
	self.image = love.graphics.newImage(self.imageFile)
	self.animated = true

	s.width = Width
	s.height = Height

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

function Sprite:createGraphic(Width, Height, Color, Alpha)
	self.width = Width
	self.height = Height
	self.color = Color
	self.alpha = Alpha
end

--[[Dispose of the object
--]]
function Sprite:destroy()
	for k, v in ipairs(self) do
		self[k] = nil
	end
	self = nil
end

function Sprite:kill()
	self.alive = false
	self.exists = false
end

function Sprite:reset(X, Y)
	self.exists = true
	self.alive = true
	self.x = X or self.x
	self.y = Y or self.y
	self.last.x = X or self.x
	self.last.y = Y or self.y
	self.velocityX = 0
	self.velocityY = 0
	self.touching = self.NONE
end

function Sprite:hurt(Damage)
	self.health = self.health - Damage
	if self.health <= 0 then
		self:kill()
	end
end

function Sprite:hardCollide(Object1, Object2)
	Object1:hurt(Object2.attackPower)
	Object2:hurt(Object1.attackPower)
end

-- updates velocity and position of sprite
function Sprite:update()
	if not self.active or not self.exists then
		return
	end
	
	if self.flickerDuration > 0 then
		self.visible = not self.visible
		self.flickerDuration = self.flickerDuration - General.elapsed
		if self.flickerDuration <= 0 then
			self.visible = true
		end
	end
	
	self.last.x = self.x
	self.last.y = self.y
	
	self.lifetime = self.lifetime + General.elapsed
	
	self.touchingPrev = self.touching
	self.touching = Sprite.NONE
	
	--Apply either drag or acceleration to velocity
	if self.accelerationX == 0 then
		if self.dragX > math.abs(self.velocityX) then
			self.velocityX = 0
		else
			self.velocityX = self.velocityX - self.dragX * Utility:signOf(self.velocityX)
		end
	else
		self.velocityX = self.velocityX + self.accelerationX * General.elapsed
	end
	--Limit velocity to maximum
	if (self.maxVelocityX >= 0) and (math.abs(self.velocityX) > self.maxVelocityX) then
		self.velocityX = self.maxVelocityX * Utility:signOf(self.velocityX)
	end

	--Apply either drag or acceleration to velocity
	if self.accelerationY == 0 then
		if self.dragY > math.abs(self.velocityY) then
			self.velocityY = 0
		else
			self.velocityY = self.velocityY - self.dragY * Utility:signOf(self.velocityY)
		end
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
	
	--Lock to screen handling
	if (self.lockSides > Sprite.NONE) then
		local camera = General:getCamera()
	
		self.touching = Sprite.NONE
		
		local locks = self.lockSides
		
		if (self.y < camera.y * self.scrollFactorY) and
			(locks % Sprite.ALL == 0 or locks % Sprite.UP == 0 or locks % Sprite.UPDOWN == 0) then
			self.y = camera.y * self.scrollFactorY
			self.velocityY = -self.velocityY * self.bounceFactor
			self.touching = Sprite.UP
		elseif (self.y + self.height > camera.y * self.scrollFactorY + camera.height)
			and (locks % Sprite.ALL == 0 or locks % Sprite.DOWN == 0 or locks % Sprite.UPDOWN == 0) then
			self.y = camera.y * self.scrollFactorY + camera.height - self.height
			self.velocityY = -self.velocityY * self.bounceFactor
			self.touching = Sprite.DOWN
		end
		if (self.x < camera.x * self.scrollFactorX)
			and (locks % Sprite.ALL == 0 or locks % Sprite.LEFT == 0 or locks % Sprite.SIDES == 0) then
			self.x = camera.x * self.scrollFactorX
			self.velocityX = -self.velocityX * self.bounceFactor
			self.touching = Sprite.LEFT
		elseif (self.x + self.width > camera.x * self.scrollFactorX + camera.width)
			and (locks % Sprite.ALL == 0 or locks % Sprite.RIGHT == 0 or locks % Sprite.SIDES == 0) then
			self.x = camera.x * self.scrollFactorX + camera.width - self.width
			self.velocityX = -self.velocityX * self.bounceFactor
			self.touching = Sprite.RIGHT
		end
	end

	--Update animations
	if (self.animated) then
		self:updateAnimation()
	end
end

--[[Draw sprite to screen
--]]
function Sprite:draw()
	if not self.visible or not self.exists then
		return
	end
	
	local camera = General:getCamera()
	
	love.graphics.setColor(self.color, self.alpha)
	if self.image == nil then
		love.graphics.rectangle(
			"fill",
			self.x,
			self.y,
			self.width,
			self.height
		)
	elseif self.animated then
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

--[[Set the collision area of the sprite
--]]
function Sprite:setCollisionBox(X, Y, W, H)
	self.x = self.x + X - self.offsetX
	self.y = self.y + Y - self.offsetY
	
	self.offsetX = X
	self.offsetY = Y
	self.width = W
	self.height = H
end
--[[Find if the sprite is touching something in a direction
--]]
function Sprite:isTouching(Direction)
	--return bit32.band(Direction, self.touching) ~= Sprite.NONE
	
end
function Sprite:justTouched(Direction)
	return (bit32.band(Direction, self.touching) ~= Sprite.NONE) and (bit32.band(Direction, self.touchingPrev) == Sprite.NONE)
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
--[[Reset image to default
--]]
function Sprite:resetImage()
	self.imageFile = nil
	self.image = nil
	self.animated = false
	self.width = nil
	self.height = nil
end
function Sprite:setScale(X, Y)
	if X == 0 then
		X = .00001
	end
	if Y == 0 then
		Y = .00001
	end
	self.width = (X / self.scaleX) * self.width
	self.height = (Y / self.scaleY) * self.height
	self.scaleX = X
	self.scaleY = Y
end



--[[Add an animation to the sprite
	AName	Name of the animation
	Frames	Table containing the ordered list of frames to be used
	FrameTime	Seconds each frame lasts
	Loop	True or False to have animation repeat when finished
--]]
function Sprite:addAnimation(AName, Frames, FrameTime, Loop)
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
function Sprite:playAnimation(AName,Restart,MustFinish)
	if Restart == nil then
		Restart = false
	end
	if MustFinish == nil then
		MustFinish = false
	end

	if self.curAnim ~= nil then
		--Cancel if trying to play the active animation, but neither forced restart nor finished
		if not Restart and (AName == self.curAnim.name) and not self.animFinished then
			return
		end
	
		--Cancel if trying to replay current non-looping animation
		if AName == self.curAnim.name and self.animFinished and not self.curAnim.loop and not Restart then
			return
		end
	end
	
	if self.animMustFinish and not self.animFinished and not Restart then
		--Let current locked animation finish
		return
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
	self.animMustFinish = MustFinish
end
--[[ Restart the currently running animation
]]
function Sprite:restartAnimation()
	self.curAnimFrame = 1
	self.animTimer = self.curAnim.frameTime
	self.animFinished = false
end
--[[Determine the current frame for an animated sprite
]]
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

function Sprite:flicker(Duration)
	self.flickerDuration = Duration
end

--[[Prevent sprite from moving offscreen during update()
--]]
function Sprite:lockToScreen(value)
	self.lockSides = value or Sprite.ALL
end

function Sprite:getLeft()
	--return self.x - self.offsetX
	return self.x
end
function Sprite:getRight()
	--return self.x + self.offsetX + self.width
	return self.x + self.width
end
function Sprite:getTop()
	--return self.y - self.offsetY
	return self.y
end
function Sprite:getBottom()
	--return self.y + self.offsetY + self.height
	return self.y + self.height
end
function Sprite:getCenter()
	--return self.x + self.offsetX + self.width/2, self.y + self.offsetY + self.height/2
	return self.x + self.width/2, self.y + self.height/2
end
function Sprite:onScreen()
	local camera = General:getCamera()
	if self.x - (General:getCamera().x * self.scrollFactorX) + self.width < 0 or
		self.x - (General:getCamera().x * self.scrollFactorX) > General.screenW then
		if self.y - (General:getCamera().y * self.scrollFactorY) + self.height < 0 or
			self.y - (General:getCamera().y * self.scrollFactorY) > General.screenH then
			return false
		end
	else
		return true
	end
end

function Sprite:getScreenX()
	return self.x - (General:getCamera().x * self.scrollFactorX)
end
function Sprite:getScreenY()
	return self.y - (General:getCamera().y * self.scrollFactorY)
end
	
function Sprite:getPosition()
	return self.x, self.y
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
	if self.touching ~= Sprite.NONE then
		debugStr = debugStr .. "\t Touching = " .. self.touching .. "\n"
	end
	if self.lockSides ~= Sprite.NONE then
		debugStr = debugStr .. "\t Screen Lock = " .. self.lockSides .. "\n"
	end
	if self.animated then
		debugStr = debugStr .. "\t Animation: \"" .. self.curAnim.name .. "\" (Frame " .. self.curAnim.frames[self.curAnimFrame] .. ")\n"
	end
	
	return debugStr
end

return Sprite

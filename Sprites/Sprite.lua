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
	angle = 0,	--Rotation of sprite, in radians
	originX = 0,	--Origin for transformations
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
	killOffScreen = false,
	animated = false,
	animations = {},	--List of animations registered for sprite
	curAnim = nil,		--Table for current animation
	curAnimFrame = 1,	--Frame index for the currently playing animation
	curImageQuad = 1,	--Index for the current current graphic in the image file
	lastAnimFrame = 1,
	animTimer = 0,		--Timer measuring between animation frames
	animFinished = false,	--Whether the current animation has finished
	animMustFinish = false,	--Whether an animation must finish before another can be played
	curFrameImage = nil,
	quadFrameCount = 1,
	imageQuads = {},	--Table containing quads for each animation frame
	immovable = false,	--Object cannot be pushed by objects during collision
	massless = false,	--Object won't push objects during collision
	bounceFactor = 0,	--Percentage of speed retained after collision
	exists = true,		--Whether the sprite has any calls done on it
	active = true,		--Whether the sprite should update
	visible = true,		--Whether the sprite should draw
	solid = true,		--Whether the sprite responds to collisions
	alive = true,
	lifetime = 0,		--How long this sprite has existed
	health = 1,
	maxhealth = 1,
	attackPower = 0,	--Innate damage of sprite (damages other sprites by this amount during HardCollide())
	showDebug = false,
	last = nil,			--Storage of value from last frame
	flickerDuration = 0,
	flashColor = nil,
	flashDuration = 0,
	flashAlpha = 0,
	flashFinished = false,
	flashLoop = false
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

	
	s.x = X or 0
	s.y = Y or 0
	if (ImageFile ~= nil) then
		s.imageFile = ImageFile
		s.image = love.graphics.newImage(s.imageFile)
		s.width = Width or s.image:getWidth()
		s.height = Height or s.image:getHeight()
	end
	s.scrollFactorX = 1
	s.scrollFactorY = 1
	s.offsetX = 0
	s.offsetY = 0
	s.originX = 0
	s.originY = 0
	s.angle = 0
	
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
		x = X or 0,
		y = Y or 0
	}
	
	s.flashColor = nil
	s.flashDuration = 0
	s.flashAlpha = 0
	s.flashFinished = false
	s.flashLoop = false
	
	return s
end

--[[ Load an animated sprite sheet
	ImageFile	Image file of sprite sheet
	Width		Pixel width of each frame (Must be exact factor of image width)
	Height		Pixel height of each frame (Must be exact factor of image height)
]]
function Sprite:loadSpriteSheet(ImageFile, Width, Height)
	--Load image
	self.imageFile = ImageFile
	self.image = love.graphics.newImage(self.imageFile)
	self.animated = true

	--Set default collision bounds
	self.width = Width
	self.height = Height

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

--[[ Create a basic rectangle graphic for the sprite
	Width		Width of sprite
	Height		Height of sprite
	Color		Color of the sprite {R,G,B}
	Alpha		Opacity of the sprite (255=Solid, 0=Clear)
]]
function Sprite:createGraphic(Width, Height, Color, Alpha)
	self.width = Width
	self.height = Height
	self.color = Color or {255,255,255}
	self.alpha = Alpha or 255
end

function Sprite:loadImage(ImageFile)
	self.imageFile = ImageFile
	self.image = love.graphics.newImage(ImageFile)
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
end

--[[ Set a color to draw over the object
	Color	{R,G,B} color to draw. {255,255,255} = no overlay
]]
function Sprite:setColor(Color)
	self.color = Color or {255,255,255}
end
--[[ Set opacity of Sprite
	Alpha	Opacity of sprite (255=Solid, 0=Clear)
]]
function Sprite:setAlpha(Alpha)
	self.alpha = Alpha or 255
end

--[[ Dispose of the object
]]
function Sprite:destroy()
	for k, v in ipairs(self) do
		self[k] = nil
	end
	self = nil
end

--[[ Kill the sprite
]]
function Sprite:kill()
	self.alive = false
	self.exists = false
end

--[[ Reset the sprite at a position
	X	X position to move to
	Y	Y position to move to
]]
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

--[[ Damage the Sprite's health by an amount
	Damage			Amount to lower health by
	OverrideValue	(Optional) Apply damage to this field (given as string) instead
]]
function Sprite:hurt(Damage, OverrideValue)
	if OverrideValue ~= nil then
		self[OverrideValue] = self[OverrideValue] - Damage
	else
		self.health = self.health - Damage
		if self.health <= 0 then
			self:kill()
		end
	end
end

--[[ Damage two objects, based on each's attack power. Does NOT do collision resolution.
	Object1		First object (damaged by Object2)
	Object2		First object (damaged by Object1)
]]
function Sprite:hardCollide(Object1, Object2)
	Object1:hurt(Object2.attackPower)
	Object2:hurt(Object1.attackPower)
end

--[[ Basic update logic for a Sprite
]]
function Sprite:update()
	if self.flickerDuration > 0 then
		local duration = self.flickerDuration
		self.visible = not self.visible
		duration = duration - General.elapsed
		if duration <= 0 then
			self.visible = true
		end
		self.flickerDuration = duration
	end
	
	self.last.x = self.x
	self.last.y = self.y
	
	self.lifetime = self.lifetime + General.elapsed
	
	self.touchingPrev = self.touching
	self.touching = Sprite.NONE
	
	local vX = self.velocityX
	local vY = self.velocityY
	
	--Apply either drag or acceleration to velocity
	if self.accelerationX == 0 then
		if self.dragX > math.abs(vX) then
			vX = 0
		else
			vX = vX - self.dragX * Utility:signOf(vX) * General.elapsed
		end
	else
		vX = vX + self.accelerationX * General.elapsed
	end
	--Limit velocity to maximum
	if (self.maxVelocityX >= 0) and (math.abs(vX) > self.maxVelocityX) then
		vX = self.maxVelocityX * Utility:signOf(vX)
	end

	--Apply either drag or acceleration to velocity
	if self.accelerationY == 0 then
		if self.dragY > math.abs(vY) then
			vY = 0
		else
			vY = vY - self.dragY * Utility:signOf(vY) * General.elapsed
		end
	else
		vY = vY + self.accelerationY * General.elapsed
	end
	--Limit velocity to maximum
	if (self.maxVelocityY >= 0) and (math.abs(vY) > self.maxVelocityY) then
		vY = self.maxVelocityY * Utility:signOf(vY)
	end
	
	if (math.abs(vX) < Sprite.VELOCITY_THRESHOLD) then
		vX = 0
	end
	if (math.abs(vX) < Sprite.VELOCITY_THRESHOLD) then
		vX = 0
	end

	--Apply velocity to position
	self.x = self.x + vX * General.elapsed
	self.y = self.y + vY * General.elapsed
	
	
	--Lock to screen handling
	if (self.lockSides > Sprite.NONE) then
		local camera = General:getCamera()
	
		self.touching = Sprite.NONE
		
		local locks = self.lockSides
		
		if (self.y < camera.y * self.scrollFactorY) and
			(locks % Sprite.ALL == 0 or locks % Sprite.UP == 0 or locks % Sprite.UPDOWN == 0) then
			self.y = camera.y * self.scrollFactorY
			vY = -vY * self.bounceFactor
			self.touching = Sprite.UP
		elseif (self.y + self.height > camera.y * self.scrollFactorY + camera.height)
			and (locks % Sprite.ALL == 0 or locks % Sprite.DOWN == 0 or locks % Sprite.UPDOWN == 0) then
			self.y = camera.y * self.scrollFactorY + camera.height - self.height
			vY = -vY * self.bounceFactor
			self.touching = Sprite.DOWN
		end
		if (self.x < camera.x * self.scrollFactorX)
			and (locks % Sprite.ALL == 0 or locks % Sprite.LEFT == 0 or locks % Sprite.SIDES == 0) then
			self.x = camera.x * self.scrollFactorX
			vX = -vX * self.bounceFactor
			self.touching = Sprite.LEFT
		elseif (self.x + self.width > camera.x * self.scrollFactorX + camera.width)
			and (locks % Sprite.ALL == 0 or locks % Sprite.RIGHT == 0 or locks % Sprite.SIDES == 0) then
			self.x = camera.x * self.scrollFactorX + camera.width - self.width
			vX = -vX * self.bounceFactor
			self.touching = Sprite.RIGHT
		end
	elseif self.killOffScreen then
		if not self:onScreen() then
			self:kill()
		end
	end

	self.velocityX = vX
	self.velocityY = vY

	--Update animations
	if (self.animated) then
		self:updateAnimation()
	end
end

--[[ Draw sprite to the screen
]]
function Sprite:draw()
	local camera = General:getCamera()
	local color
	if self.flashAlpha > 0 then
		local flashAlpha = self.flashAlpha
		
		if not self.flashFinished then
			flashAlpha = flashAlpha + 255*General.elapsed/self.flashDuration
			if flashAlpha > 255 then
				flashAlpha = 255
				self.flashFinished = true
			end
		else
			flashAlpha = flashAlpha - 255*General.elapsed/self.flashDuration
			if flashAlpha < 0 then
				if self.flashLoop then
					flashAlpha = 0.001
					self.flashFinished = false
				else
					flashAlpha = 0
				end
			end
		end
		local dR = 1-self.flashColor[1]/255
		local dG = 1-self.flashColor[2]/255
		local dB = 1-self.flashColor[3]/255
		color = {255-flashAlpha*dR, 255-flashAlpha*dG, 255-flashAlpha*dB}
		self.flashAlpha = flashAlpha
	else
		color = self.color
	end
	love.graphics.setColor(color[1], color[2], color[3], self.alpha)
	if self.image == nil then
		love.graphics.rectangle(
			"fill",
			self.x - (self.scaleX * self.originX),
			self.y - (self.scaleY * self.originY),
			self.width * self.scaleX,
			self.height * self.scaleY
		)
	elseif self.animated then
		love.graphics.draw(
			self.image, self.imageQuads[self.curAnim.frames[self.curAnimFrame]],
			self.x - (camera.x * self.scrollFactorX) + (self.originX),
			self.y - (camera.y * self.scrollFactorY) + (self.originY),
			self.angle,
			self.scaleX, self.scaleY,
			self.offsetX + self.originX, self.offsetY + self.originY
		)
	else
		love.graphics.draw(
			self.image,
			self.x - (camera.x * self.scrollFactorX) + (self.originX),
			self.y - (camera.y * self.scrollFactorY) + (self.originY),
			self.angle,
			self.scaleX, self.scaleY,
			self.offsetX + self.originX, self.offsetY  + self.originY
		)
	end
	if General.showBounds then
		local r,g,b = 0,0,0
		if self.solid then
			r = 255
		end
		if self.massless then
			g = 255
		end
		if self.immovable then
			b = 255
		end
		love.graphics.setColor(r,g,b,255)
		love.graphics.rectangle(
			"line",
			self.x - (camera.x * self.scrollFactorX),
			self.y - (camera.y * self.scrollFactorY),
			self.width,
			self.height
		)
	end
end

--[[ Set the collision area of the sprite
	X	Offset from left of image file to left of collision box
	Y	Offset from top of image file to top of collision box
	W	Collidable width (from offset) of sprite
	H	Collidable height (from offset) of sprite
]]
function Sprite:setCollisionBox(X, Y, W, H)
	self.x = self.x + X - self.offsetX
	self.y = self.y + Y - self.offsetY
	
	self.offsetX = X
	self.offsetY = Y
	self.width = W
	self.height = H
end

--[[ Load an animated sprite sheet
	ImageFile	Filename for sheet to load
	Width		Pixel width of each frame
	Height		Pixel height of each frame
]]
function Sprite:loadSpriteSheet(ImageFile, Width, Height)
	--Load image
	self.imageFile = ImageFile
	self.image = love.graphics.newImage(self.imageFile)
	self.animated = true
	
	self.width = Width
	self.height = Height

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

--[[ Reset image to default
]]
function Sprite:resetImage()
	self.imageFile = nil
	self.image = nil
	self.animated = false
	self.width = nil
	self.height = nil
end
--[[ Set the size scale of the Sprite (Scales image/collision)
	X	Horizontal scale multiplier
	Y	Vertical scale multiplier
]]
function Sprite:setScale(X, Y)
	if X == 0 then
		X = .00001
	end
	if Y == 0 then
		Y = .00001
	end
	--Rescale bounds, accounting for old scale
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
							loop = Loop}
end

--[[ Start an animation
	AName		Name of animation to play
	Restart		Force animation to restart from beginning
	MustFinish	The animation must finish before another can play
]]
function Sprite:playAnimation(AName,Restart,MustFinish)
	--Set defaults
	if Restart == nil then
		Restart = false
	end
	if MustFinish == nil then
		MustFinish = false
	end

	if self.curAnim ~= nil then
		--An animation is already playing
		if AName == self.curAnim.name and not Restart then
			--Cancel if trying to play the active animation, but not forcing restart
			return
		end
	
		if AName == self.curAnim.name and self.animFinished
			and not self.curAnim.loop and not Restart then
			--Cancel if trying to replay current, non-looping animation (and not forced)
			return
		end
	end
	
	if self.animMustFinish and not self.animFinished and not Restart then
		--Let current locked animation finish
		return
	end
	
	--Check that the called animation exists
	if (self.animations[AName] == nil) then
		self:resetImage()
		self.imageFile = "[ERROR: Animation \"" .. AName .. "\" not defined]"
		self.image = love.graphics.newImage("images/err_noAnim.png")
		return
	end
	
	--Start animation
	self.curAnim = self.animations[AName]
	self.lastAnimFrame = 1
	self.curAnimFrame = 1
	self.animTimer = self.curAnim.frameTime
	self.animFinished = false
	self.animMustFinish = MustFinish
end

--[[ Restart the currently running animation
]]
function Sprite:restartAnimation()
	self.lastAnimFrame = self.curAnimFrame
	self.curAnimFrame = 1
	self.animTimer = self.curAnim.frameTime
	self.animFinished = false
end

--[[Determine the current frame for an animated sprite
]]
function Sprite:updateAnimation()
	if not self.animated or self.curAnim == nil then
		--Cancel if not animating
		return
	end
	
	--Update if looping or animation has not yet finished
	if (self.curAnim.loop or not self.animFinished) then
		--Update timer
		self.animTimer = self.animTimer - General.elapsed
		
		if self.animTimer <= 0 then
			--Frame timer finished, reset and advance frame
			self.animTimer = self.curAnim.frameTime
			
			if self.curAnimFrame == table.getn(self.curAnim.frames) then
				--Last frame of animation
				
				if self.curAnim.loop then
					--Restart if looping
					self.lastAnimFrame = self.curAnimFrame
					self.curAnimFrame = 1
				end
				--Animation has completed once, mark as finished
				self.animFinished = true
			else
				--Not yet finished, go to next frame
				self.lastAnimFrame = self.curAnimFrame
				self.curAnimFrame = self.curAnimFrame + 1
			end
			
			--Set the quad index for this frame
			self.curImageQuad = self.curAnim.frames[self.curAnimFrame]
		end
	end
end

--[[ Flicker the Sprite for a given time
	Duration	Time in seconds for sprite to flicker
]]
function Sprite:flicker(Duration)
	self.flickerDuration = Duration
end
--[[ Flash a color overlay on the sprite
	FlashColor		Color to overlay {R,G,B}
	FlashDuration	Time for flash (total)
]]
function Sprite:flash(FlashColor, FlashDuration, Loop)
	self.flashColor = FlashColor
	self.flashDuration = FlashDuration * .5
	self.flashAlpha = 0.001
	self.flashFinished = false
	if Loop == nil then
		Loop = false
	end
	self.flashLoop = Loop
end

function Sprite:clearFx()
	self.flashAlpha = 0
	self.flickerDuration = 0
end

--[[Prevent sprite from moving offscreen
]]
function Sprite:lockToScreen(value)
	self.lockSides = value or Sprite.ALL
end

function Sprite:isFlickering()
	return (self.flickerDuration > 0)
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
	if self.x - (camera.x * self.scrollFactorX) + self.width < 0 or
		self.x - (camera.x * self.scrollFactorX) > General.screenW then
		if self.y - (camera.y * self.scrollFactorY) + self.height < 0 or
			self.y - (camera.y * self.scrollFactorY) > General.screenH then
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

function Sprite:hide()
	self.visible = false
end

function Sprite:show()
	self.visible = true
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
		debugStr = debugStr .. "\t Animation: \"" .. self.curAnim.name .. "\" (Frame " .. self.curAnimFrame .. ")\n"
	end
	
	return debugStr
end


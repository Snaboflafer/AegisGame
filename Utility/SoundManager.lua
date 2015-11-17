SoundManager = {}

SoundManager.queue = {}
SoundManager.bgm = nil
SoundManager.stoppingBgm = false
SoundManager.changingBgm = false
SoundManager.newBgmName = ""
SoundManager.elapsedTime = 0

--love.audio.setVolume(.05)

--play a sound
function SoundManager:play(sndData)
   --make a source out of the sound data
   local src = love.audio.newSource(sndData, "static")
   --put it in the queue
   table.insert(self.queue, src)
   --and play it
   love.audio.play(src)
end

--play a bgm track
function SoundManager:playBgm(sndData)
   --stop currently playing bgm
   if self.bgm ~= nil then
   	self.changingBgm = true
   	self.newBgmName = sndData
   	self.elapsedTime = 0
   else
   		self.bgm = love.audio.newSource(sndData)
   		self.bgm:setLooping(true)
   		love.audio.play(self.bgm)
   	end
end


--stop bgm
function SoundManager:stopBgm()
	self.stoppingBgm = true
end

--update
function SoundManager:update(dt)
   --check which sounds in the queue have finished, and remove them
   local removelist = {}
   for i, v in ipairs(self.queue) do
      if v:isStopped() then
         table.insert(removelist, i)
      end
   end
   --we can't remove them in the loop, so use another loop
   for i, v in ipairs(removelist) do
      table.remove(self.queue, v-i+1)
   end
   --do fade out if necessary
   if self.changingBgm then
   		SoundManager:changeBgm(dt)
   elseif self.stoppingBgm then
   		SoundManager:fadeOutBgm(dt)
   end
   --play bgm
   if self.bgm ~= nil then
   	  love.audio.play(self.bgm)  --delete?
   end
end

--helper functions

--changes the bgm from one track to another
function SoundManager:changeBgm(dt)
    SoundManager:fadeOutBgm(dt)
    --done fading out
    if SoundManager.bgm:getVolume() <= 0 then
    	SoundManager.changingBgm = false
    	--play new bgm
    	SoundManager.bgm = love.audio.newSource(SoundManager.newBgmName)
   		SoundManager.bgm:setLooping(true)
   		love.audio.play(SoundManager.bgm)
	end
end

--fades out bgm
function SoundManager:fadeOutBgm(dt)
	self.bgm:setVolume(math.max(self.bgm:getVolume() - dt, 0))
	if self.bgm:getVolume() <= 0 then
		self.bgm:stop()
		self.stoppingBgm = false
	end
end
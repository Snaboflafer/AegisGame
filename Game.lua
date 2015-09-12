--Basic class for game overview
snbGame = {
	state = {}
}

local function new(self)
	self = self or {}
	
	--self.state = initialState
	
	--local LIBsnbG = require("snbG")
	--local LIBsnbAudio = require("snbAudio")
	--local LIBsnbBasic = require("snbBasic")
	--snbG = LIBsnbG.init()
	--snbAudio = LIBsnbAudio.init()
	--snbBasic = LIBsnbBasic.init()

	return self
end

local function setState(self, newState)
	if (state ~= nil) then
		state.destroy()
	end
	
	state = newState
end


return {
	new=new
}
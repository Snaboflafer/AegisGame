--- Paused screen state.
PauseState = {
	title = "GAME PAUSED",
	options = {
		"Resume",
		"High Scores",
		"Brightness",
		"Volume",
		"Quit"
	}
}
PauseState.__index = PauseState
setmetatable(PauseState, MenuState)

--function PauseState:load()

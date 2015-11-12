--[[ Custom action (script demo)
	Shows a series of message boxes, using a single message
]]

--Show the message box.
GameState.messageBox:show("Lorem ipsum dolor sit amet, consectetur adipiscing elit. " ..
"Suspendisse cursus ante in aliquam aliquam. In tempor mi nec accumsan lobortis. " ..
"Maecenas pulvinar, nunc id fringilla, urna enim semper odio, sed varius " ..
"lorem massa eget ex. Quisque aliquam pellentesque leo, id scelerisque turpis ornare fringilla.")

--Mark script as finished			
stage = -1

return stage
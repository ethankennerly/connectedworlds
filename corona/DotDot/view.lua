-- http://ragdogstudios.com/2014/01/04/convert-hex-to-rgb-values-to-new-corona-sdk-standards/
local ragDogLib = require "ragDogLib"


local view = {
	lineColor = "006699",
	lineThickness = 48.0,
	lines = nil,
	model = nil,
}

function view:populate(model)
	view.model = model
	view:drawLines()
end


-- http://gamedev.stackexchange.com/questions/69810/how-can-i-clear-the-entire-display-in-corona
function view:drawLines()
	if view.lines then
		view.lines.removeSelf()
	end
	view.lines = display.newGroup()
	local line = display.newLine(-113, 133, 113, -113)
	line:setStrokeColor(ragDogLib.convertHexToRGB(view.lineColor))
	line.strokeWidth = view.lineThickness
	line.x = display.contentCenterX - line.height * 0.75
	line.y = display.contentCenterY + line.height * 0.75
	line.xScale = 2.0
	line.yScale = 2.0
end

return view

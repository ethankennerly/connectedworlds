-- http://ragdogstudios.com/2014/01/04/convert-hex-to-rgb-values-to-new-corona-sdk-standards/
local ragDogLib = require "ragDogLib"


local view = {
	dots = nil,
	lineColor = "006699",
	lineThickness = 48.0,
	lines = nil,
	model = nil,
}

function view:populate(model)
	view.model = model
	view:drawDots()
	view:drawLines()
end


function view:drawDots()
	view.dots = {}
end


-- http://gamedev.stackexchange.com/questions/69810/how-can-i-clear-the-entire-display-in-corona
function view:drawLines()
	if view.lines then
		view.lines.removeSelf()
	end
	view.lines = display.newGroup()
	local line = nil
	local first = true
	for key, ij in next, view.model.connections, nil do
		local xy1 = view.model.dots[ij[1]]
		local xy2 = view.model.dots[ij[2]]
		if first then
			line = display.newLine(xy1[1], xy1[2], xy2[1], xy2[2])
		else
			line:append(xy1[1], xy1[2], xy2[1], xy2[2])
		end
		first = false
	end
	line:setStrokeColor(ragDogLib.convertHexToRGB(view.lineColor))
	line.strokeWidth = view.lineThickness
	view.lines:insert(line)
	view.lines.x = display.contentCenterX
	view.lines.y = display.contentCenterY
	view.lines.xScale = 2.0
	view.lines.yScale = 2.0
end

return view

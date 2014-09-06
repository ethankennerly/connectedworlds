-- http://ragdogstudios.com/2014/01/04/convert-hex-to-rgb-values-to-new-corona-sdk-standards/
local ragDogLib = require "ragDogLib"


local view = {
	dotGroup = nil,
	dots = nil,
	lineColor = "006699",
	lineThickness = 48.0,
	lineGroup = nil,
	model = nil,
	screen = nil,
}

function view:populate(model)
	view.model = model
	view:newScreen()
	view:drawDots()
	view:drawLines()
end


function view:newScreen()
	view.screen = display.newGroup()
	view.screen.x = display.contentCenterX
	view.screen.y = display.contentCenterY
	view.screen.xScale = 2.0
	view.screen.yScale = 2.0
end

function view:drawDots()
	view.dots = {} 
	if view.dotGroup then
		view.dotGroup:removeSelf()
	end
	view.dotGroup = display.newGroup()
	for key, xy in next, view.model.dots, nil do
		local dot = display.newImage( "dot.png", xy[1], xy[2])
		view.dots[ #view.dots + 1 ] = dot
		view.dotGroup:insert(dot)
	end
	view.screen:insert(view.dotGroup)
end


-- http://gamedev.stackexchange.com/questions/69810/how-can-i-clear-the-entire-display-in-corona
function view:drawLines()
	if view.lineGroup then
		view.lineGroup:removeSelf()
	end
	view.lineGroup = display.newGroup()
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
	view.lineGroup:insert(line)
	view.screen:insert(view.lineGroup)
end

function view:clearLines()
	if view.lineGroup then
		view.lineGroup:removeSelf()
	end
end

return view

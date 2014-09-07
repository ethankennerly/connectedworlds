-- http://ragdogstudios.com/2014/01/04/convert-hex-to-rgb-values-to-new-corona-sdk-standards/
local ragDogLib = require "ragDogLib"

local view = {
	dotGroup = nil,
	dots = nil,
	lineColor = "#006699",
	lineThickness = 48.0,
	lineGroup = nil,
	model = nil,
	progressColor = "#CCFFFF",
	progressGroup = nil,
	previousDot = nil,
	radius = 32,
	radiusSquared = nil,
	scale = 2.0,
	screen = nil,
}

function newView()
	view.radiusSquared = view.radius * view.radius
	view:newScreen()
	return view
end

function view:newScreen()
	if view.screen then
		view.screen:removeSelf()
	end
	view.screen = display.newGroup()
	view.screen.x = display.contentCenterX
	view.screen.y = display.contentCenterY
	view.screen.xScale = view.scale
	view.screen.yScale = view.scale
end

function view:cancel()
	view.previousDot = nil
	view:drawProgress(0, 0, 0)
end

function view:populate(model)
	view.model = model
	view:cancel()
	view:drawDots()
	view:drawLines()
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

function view:drawProgress(dotIndex, x, y)
	if view.progressGroup then
		view.progressGroup:removeSelf()
		view.progressGroup = nil
	end
	if dotIndex <= 0 then
		return
	end
	view.progressGroup = display.newGroup()
	local dot = view.dots[dotIndex]
	x, y = view.screen:contentToLocal(x, y)
	local line = display.newLine(dot.x, dot.y, x, y)
	line:setStrokeColor(ragDogLib.convertHexToRGB(view.progressColor))
	line.strokeWidth = view.lineThickness
	view.progressGroup:insert(line)
	view.screen:insert(view.progressGroup)
end

function view:near(dx, dy)
	return dx * dx + dy * dy <= view.radiusSquared
end

function view:nextDotAt(x, y)
	local at = nil
	x, y = view.screen:contentToLocal(x, y)
	for key, dot in next, view.dots, nil do
		if view:near(dot.x - x, dot.y - y) then
			if dot ~= previousDot then
				previousDot = dot
				at = dot
			end
			break
		end
	end
	return at
end

return newView()

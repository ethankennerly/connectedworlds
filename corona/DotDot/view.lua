-- http://ragdogstudios.com/2014/01/04/convert-hex-to-rgb-values-to-new-corona-sdk-standards/
local ragDogLib = require "ragDogLib"

local view = {
	connectionGroup = nil,
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
	scale = 1.5,
			-- 1.8,
			-- 2.0,
	screen = nil,
	wrongLineColor = "#FF3299",
}

function newView()
	view.radiusSquared = view.radius * view.radius
	view:newScreen()
	return view
end

function view:newScreen()
	if view.screen then
		view.screen:removeSelf()
		view.screen = nil
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

function view:clearGroup(groupName)
	if view[groupName] and view[groupName].parent then
		view[groupName]:removeSelf()
		view[groupName] = nil
	end
end

function view:clear()
	view:cancel()
	view:clearGroup("dotGroup");
	view:clearGroup("lineGroup");
	view:clearGroup("connectionGroup");
	view:clearGroup("progressGroup");
end

function view:populate(model)
	view.model = model
	view:cancel()
	view:drawDots()
	view:drawLines()
	view.connectionGroup = display.newGroup()
	view.screen:insert(view.connectionGroup)
end

function view:drawDots()
	view.dots = {}
	view:clearGroup("dotGroup");
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
		view.lineGroup = nil
	end
	view.lineGroup = display.newGroup()
	for key, ij in next, view.model.connections, nil do
		local xy1 = view.model.dots[ij[1]]
		local xy2 = view.model.dots[ij[2]]
		local line = display.newLine(xy1[1], xy1[2], xy2[1], xy2[2])
		line:setStrokeColor(ragDogLib.convertHexToRGB(view.lineColor))
		line.strokeWidth = view.lineThickness
		view.lineGroup:insert(line)
	end
	view.screen:insert(view.lineGroup)
end

function view:clearLines()
	if view.lineGroup then
		view.lineGroup:removeSelf()
		view.lineGroup = nil
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

function view:drawConnection(fromDotIndex, toDotIndex, correct)
	if fromDotIndex <= 0 or toDotIndex <= 0 then
		return
	end
	local dot0 = view.dots[fromDotIndex]
	local dot1 = view.dots[toDotIndex]
	local line = display.newLine(dot0.x, dot0.y, dot1.x, dot1.y)
	local color = correct and view.lineColor or view.wrongLineColor
	line:setStrokeColor(ragDogLib.convertHexToRGB(color))
	line.strokeWidth = view.lineThickness
	view.connectionGroup:insert(line)
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

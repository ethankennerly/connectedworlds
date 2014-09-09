-- http://ragdogstudios.com/2014/01/04/convert-hex-to-rgb-values-to-new-corona-sdk-standards/
local ragdoglib = require "ragdoglib"
local prompt = require "prompt"

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
	view.connectionGroup = display.newGroup()
	view.progressGroup = display.newGroup()
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

-- Remove children.  Keep self.
function view:clearGroup(groupName)
	if view[groupName] and view[groupName].parent then
		while 1 <= view[groupName].numChildren do
			local childIndex = view[groupName].numChildren
			view[groupName][childIndex]:removeSelf()
		end
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
	view.screen:insert(view.connectionGroup)
	view.screen:insert(view.progressGroup)
	view:screenBegin()
end

function view:screenBegin() 
 	local fadeMilliseconds = 7.0 / 30.0 * 1000.0
	view.lineGroup.alpha = 0.0
 	transition.fadeIn(view.lineGroup, {time = fadeMilliseconds})
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
		line:setStrokeColor(ragdoglib.convertHexToRGB(view.lineColor))
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
	prompt:destroy()
end

function view:drawProgress(dotIndex, x, y)
	view:clearGroup("progressGroup")
	if dotIndex <= 0 then
		return
	end
	local dot = view.dots[dotIndex]
	x, y = view.screen:contentToLocal(x, y)
	local line = display.newLine(dot.x, dot.y, x, y)
	line:setStrokeColor(ragdoglib.convertHexToRGB(view.progressColor))
	line.strokeWidth = view.lineThickness
	view.progressGroup:insert(line)
end

function view:drawConnection(fromDotIndex, toDotIndex, correct)
	if fromDotIndex <= 0 or toDotIndex <= 0 then
		return
	end
	local dot0 = view.dots[fromDotIndex]
	local dot1 = view.dots[toDotIndex]
	local line = display.newLine(dot0.x, dot0.y, dot1.x, dot1.y)
	local color = correct and view.lineColor or view.wrongLineColor
	line:setStrokeColor(ragdoglib.convertHexToRGB(color))
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
			if dot ~= view.previousDot then
				view.previousDot = dot
				at = dot
			end
			break
		end
	end
	return at
end

-- Why does view.progressGroup:insert fail?
function view:prompt(dotIndexes)
	local dot1 = view.dots[dotIndexes[1]]
	local dot2 = view.dots[dotIndexes[2]]
	local hand = prompt:line(dot1.x, dot1.y, dot2.x, dot2.y)
	assert(view.progressGroup, "Expected progressGroup")
	assert(view.progressGroup.insert, "Expected progressGroup:insert")
	assert(hand, "Expected hand") 
	view.progressGroup:insert(hand)
	-- print(hand, hand.x, hand.y, hand.xScale)
	-- view.screen:insert(hand)
end

return newView()

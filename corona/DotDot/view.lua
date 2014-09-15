-- http://ragdogstudios.com/2014/01/04/convert-hex-to-rgb-values-to-new-corona-sdk-standards/
local ragdoglib = require "ragdoglib"
local sequence = require "sequence"
local background = require "background"
local prompt = require "prompt"

local view = {
	connectionGroup = nil,
	dotGroup = nil,
	dots = nil,
	lineColor = "#006699",
	lineThickness = 64.0,
	lineGroup = nil,
	model = nil,
	onScreenEnd = nil,
	progressColor = "#CCFFFF",
	progressGroup = nil,
	previousDot = nil,
	radius = 60,
	radiusSquared = nil,
	scale = 1.5,
			-- 1.8,
			-- 2.0,
	screen = nil,
	wrongLineColor = "#FF3299",
}

function view:new()
	view.radius = view.radius / view.scale
	view.radiusSquared = view.radius * view.radius
	view:newScreen()
	view.background = background
	view.backgroundGroup = display.newGroup()
	view.backgroundGroup:insert(background.scene)
	view.screen:insert(view.backgroundGroup)
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
	prompt:destroy()
end

function view:trialEnd()
	view:cancel()
	view:screenEnd()
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

local fadeMilliseconds = 7.0 / 30.0 * 1000.0

function view:screenBegin()
 	local dotFadeInMilliseconds = 18.0 / 30.0 * 1000.0
	view.lineGroup.alpha = 0.0
	view.dotGroup.alpha = 0.0
 	transition.fadeIn(view.lineGroup, {time = fadeMilliseconds})
 	transition.fadeIn(view.connectionGroup, {time = fadeMilliseconds})
 	transition.fadeIn(view.dotGroup, {delay = dotFadeInMilliseconds, 
									  time = fadeMilliseconds})
end

function view:screenInput()
 	transition.fadeOut(view.lineGroup, {time = fadeMilliseconds})
end

function view:screenEnd()
 	local connectionFadeOutMilliseconds = 10.0 / 30.0 * 1000.0
 	local endMilliseconds = 10.0 / 30.0 * 1000.0 + connectionFadeOutMilliseconds + fadeMilliseconds
 	transition.fadeOut(view.dotGroup, {time = fadeMilliseconds})
 	transition.fadeOut(view.connectionGroup, {delay = connectionFadeOutMilliseconds, 
									  time = fadeMilliseconds})
 	transition.to(view.lineGroup, {delay = endMilliseconds, 
									  time = 0.0, onComplete = view.onScreenEnd})
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
		view:drawLineRounded(view.lineGroup, 
			xy1[1], xy1[2], xy2[1], xy2[2], view.lineColor)
	end
	view.screen:insert(view.lineGroup)
end

function view:clearLines()
	prompt:destroy()
	view:screenInput()
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
	if toDotIndex <= 0 then
		return
	end
	local dot2 = view.dots[toDotIndex]
	view:animateDot(dot2)
	if fromDotIndex <= 0 then
		return
	end
	local dot1 = view.dots[fromDotIndex]
	local color = correct and view.lineColor or view.wrongLineColor
	view:drawLineRounded(view.connectionGroup, 
		dot1.x, dot1.y, dot2.x, dot2.y, color)
end

function view:drawLineRounded(group, x1, y1, x2, y2, color)
	local line = display.newLine(x1, y1, x2, y2)
	local r, g, b = ragdoglib.convertHexToRGB(color)
	line:setStrokeColor(r, g, b)
	line.strokeWidth = view.lineThickness
	group:insert(line)
	local radius = view.lineThickness * 0.5
	local circle0 = display.newCircle(x1, y1, radius)
	circle0:setFillColor(r, g, b)
	group:insert(circle0)
	local circle1 = display.newCircle(x2, y2, radius)
	circle1:setFillColor(r, g, b)
	group:insert(circle1)
end

function view:animateDot(dot)
	local ring = display.newImage("dotconnectedring.png", dot.x, dot.y)
	view.dotGroup:insert(ring)
	local bigMilliseconds = 3.0 / 30.0 * 1000.0 
	local smallMilliseconds = 8.0 / 30.0 * 1000.0
	sequence:to(ring, false, 
		{time = bigMilliseconds, xScale = 3.0, yScale = 3.0},
		{time = smallMilliseconds, xScale = 1.0, yScale = 1.0, onComplete = display.remove})
end

function view:near(dx, dy)
	local distanceSquared = dx * dx + dy * dy
	if distanceSquared < view.radiusSquared then
		return distanceSquared
	else
		return math.huge
	end
end

function view:nextDotAt(x, y)
	local nearest = nil
	local nearestDistanceSquared = math.huge
	x, y = view.screen:contentToLocal(x, y)
	for key, dot in next, view.dots, nil do
		local distanceSquared = view:near(dot.x - x, dot.y - y)
		if distanceSquared < nearestDistanceSquared then
			if dot ~= view.previousDot then
				view.previousDot = dot
				nearest = dot
				nearestDistanceSquared = distanceSquared
			end
		end
	end
	return nearest
end

-- Why does view.progressGroup:insert fail?
function view:prompt(dotIndexes)
	local dot1 = view.dots[dotIndexes[1]]
	local dot2 = view.dots[dotIndexes[2]]
	local hand = prompt:line(dot1.x, dot1.y, dot2.x, dot2.y)
	view.progressGroup:insert(hand)
end

function view:hintDistractors(dotIndexes)
	for _, dotIndex in ipairs(dotIndexes) do
		local dot = view.dots[dotIndex]
		local distractorHint = display.newImage("distractor.png", dot.x, dot.y)
		view.lineGroup:insert(distractorHint)
	end
end

function view:win()
	if "trial" ~= background.currentLabel then
		background:trial()
	end
end

return view:new()

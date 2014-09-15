local copy = require "copy"
local graphs = require "graphs"

local model = {
	connecting = {},
	connections = {},
	connectionsOld = {},
	distractors = {},
	dots = {},
	from = -1,
	graphsOld = {},
	inTrial = false,
	level = 1,
	levelTutor = 7,
	linesVisible = false,
	listening = false,
	to = -1,
	tutor = false,
}

function model:new()
	model.graphsOld = {}
	return model
end

function model:cancel()
	model.connecting = {}
	model.from = -1
	model.to = -1
end

function model:populate()
	model:cancel()
	-- print("model:populate: " .. model.level)
	model.connectionsOld = {}
	local params = copy.deepcopy(graphs[model.level])
	for key, value in next, params, nil do
		model[key] = value
	end
	model.linesVisible = true
	model.inTrial = true
	model.listening = false
	model.distractors = model:findSingles(model.connections, #model.dots)
	model.tutor = model.level < model.levelTutor
end

function model:findSingles(connections, length)
	local connecteds = {}
	for _, connection in ipairs(connections) do
		for __, index in ipairs(connection) do
			connecteds[index] = true
			-- print("model:findSingles: index", index)
		end	
	end
	local singles = {}
	for index = 1, length do
		if not connecteds[index] then
			singles[#singles + 1] = index
			-- print("model:findSingles: single", index)
		end
	end
	return singles
end

function model:complete()
	return table.getn(model.connections) <= 0
end

function model:trialEnd(correct)
	if not model.inTrial then
		return
	end
	model.inTrial = false
	model.listening = false
	model.graphsOld[model.level] = true
	model.level = model:findNewLevel(correct)
	-- print("model:trialEnd: level " .. model.level)
end

function model:findNewLevel(correct)
	local level = model.level + (correct and 1 or 0)
	if #graphs < level then
		level = 1
	end
	return level
end

function model:listen()
	if model.inTrial and not model.listening then
		model.listening = true
	end
end

function model:answer(x, y)
	local result = -1
	if model:complete() then
		result = 1 
	end
	local dotIndex = 0
	for d, xy in next, model.dots, nil do
		if (x == xy[1] and y == xy[2]) then
			dotIndex = d
			break
		end
	end
	assert(1 <= dotIndex, "Expected dot at " .. x .. ", " .. y )
	local connecting = model.connecting
	if table.getn(connecting) <= 0 then
		connecting[ #connecting + 1 ] = dotIndex
	end
	connecting[ #connecting + 1 ] = dotIndex
	table.sort(connecting)
	local c = model:indexOf(model.connections, connecting)
	if 1 <= c then
		table.remove(model.connections, c)
		model.connectionsOld[ #model.connectionsOld + 1 ] = connecting
		result = 1
	end
	if connecting[1] == connecting[2] then
		result = 1
	end
	if result <= -1 then
		local old = 1 <= model:indexOf(model.connectionsOld, connecting)
		if old then
			result = 0
		end
	end
	connecting = {}
	table.insert(connecting, dotIndex)
	model.connecting = connecting
	model.from = model.to
	model.to = dotIndex
	return result
end

function model:indexOf(connections, connecting)
	local index = 0
	for c, connection in ipairs(connections) do
		if connecting[1] == connection[1] and connecting[2] == connection[2] then
			index = c
			break
		end
	end
	return index
end


return model:new()

local copy = require "copy"
local graphs = require "graphs"

local model = {
	connecting = {},
	connections = {},
	dots = {},
	from = -1,
	inTrial = false,
	level = 1,
	linesVisible = false,
	to = -1,
}

function model:cancel()
	model.connecting = {}
	model.from = -1
	model.to = -1
end

function model:populate()
	model:cancel()
	local params = copy.deepcopy(graphs[model.level])
	for key, value in next, params, nil do
		model[key] = value
	end
	model.linesVisible = true
	model.inTrial = true
end

function model:complete()
	return table.getn(model.connections) <= 0
end

function model:answer(x, y)
	local correctIndex = 0
	if model:complete() then
		correctIndex = 1
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
	for c, connection in ipairs(model.connections) do
		if connecting[1] == connection[1] and connecting[2] == connection[2] then
			table.remove(model.connections, c)
			correctIndex = dotIndex
			break
		end
	end
	if connecting[1] == connecting[2] then
		correctIndex = dotIndex
	end
	connecting = {}
	table.insert(connecting, dotIndex)
	model.from = model.to
	model.to = dotIndex
	return correctIndex
end

return model

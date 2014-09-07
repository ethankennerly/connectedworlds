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


return model

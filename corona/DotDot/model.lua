local copy = require "copy"
local graphs = require "graphs"

local model = {
	connections = {},
	dots = {},
	level = 1,
}

function model:populate()
	local params = copy.deepcopy(graphs[model.level])
	for key, value in next, params, nil do
		model[key] = value
	end
end


return model

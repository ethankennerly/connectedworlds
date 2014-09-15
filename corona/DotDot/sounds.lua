local sonata = require("sonata")

local sounds = {}

-- Sound in directory.  Simulator loads sounds in parent directories, but I'm not sure if device does.
function sounds:new()
	sounds.notes = {
		a3_f4 = audio.loadSound("kalimba_a3_f4.mp3"),
		c4 = audio.loadSound("kalimba_c4.mp3"),
		d4 = audio.loadSound("kalimba_d4.mp3"),
		d5 = audio.loadSound("kalimba_d5.mp3"),
		e4 = audio.loadSound("kalimba_e4.mp3"),
		g3 = audio.loadSound("kalimba_g3.mp3"),
	}
	sounds.sonataIndex = 1
	sounds.sonata = sonata
	return sounds
end

function sounds:correct()
	audio.play(sounds.notes[sounds.sonata[sounds.sonataIndex]])
	sounds.sonataIndex = ((sounds.sonataIndex + 1) % #sonata) + 1
end

function sounds:wrong()
	audio.play(sounds.notes.d5)
end

return sounds:new()

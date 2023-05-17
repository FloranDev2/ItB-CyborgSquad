local mod = {
	id = "truelch_CyborgSquad",
	name = "Truelch's Cyborgs",
	icon = "img/icon.png",
	version = "1.0",
	modApiVersion = "2.8.3",
	gameVersion = "1.2.88",
    dependencies = {
        modApiExt = "1.17",
		memedit = "1.0.1",
    }
}

function mod:init()
	--require(self.scriptPath .."achievements")
	require(self.scriptPath .."weapons")
	require(self.scriptPath .."pawns")
end

function mod:load(options, version)
	modApi:addSquad(
		{
			id = "tatu_Advanced_Squad",
			"Advanced Squad",
			"truelch_ScorpionMech",
			"tatu_GastropodMech",
			"tatu_StarfishMech",
		},
		"Advanced Squad",
		"Our scientists were so preoccupied with whether they could, they didn't stop to think if they should.",
		self.resourcePath .."img/icon.png"
	)
end

return mod
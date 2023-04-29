local mod = {
	id = "tatu_Advanced_Squad",
	name = "Advanced Squad",
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
	require(self.scriptPath .."achievements")
	require(self.scriptPath .."weapons")
	require(self.scriptPath .."pawns")
end

function mod:load(options, version)
	modApi:addSquad(
		{
			id = "tatu_Advanced_Squad",
			"Advanced Squad",				-- title
			"tatu_PlasmodiaMech",			-- mech #1
			"tatu_GastropodMech",			-- mech #2
			"tatu_StarfishMech",			-- mech #3
		},
		"Advanced Squad",
		"Our scientists were so preoccupied with whether they could, they didn't stop to think if they should.",
		self.resourcePath .."img/icon.png"
	)
end

return mod
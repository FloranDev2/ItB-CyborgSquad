local mod = {
	id = "truelch_Cyborg_Squad",
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
	--Assets
	require(self.scriptPath.."assets")

	--Misc
	--require(self.scriptPath .."achievements")

	--Weapons
	--require(self.scriptPath .."weapons")
	require(self.scriptPath.."/weapons/scorpion_attack")
	require(self.scriptPath.."/weapons/bouncer_attack")
	require(self.scriptPath.."/weapons/burrower_attack")

	--Pawns
	require(self.scriptPath .."pawns")
end

function mod:load(options, version)
	modApi:addSquad(
		{
			id = "truelch_Cyborg_Squad",
			"Truelch's Cyborg Squad",
			"truelch_ScorpionMech",
			"truelch_BouncerMech",
			"truelch_BurrowerMech",
		},
		"Truelch's Cyborg Squad",
		"Ah yes, more Cyborgs. Go BRRRT.",
		self.resourcePath .."img/icon.png"
	)
end

return mod
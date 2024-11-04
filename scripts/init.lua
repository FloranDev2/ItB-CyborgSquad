local mod = {
	id = "truelch_Cyborg_Squad",
	name = "Truelch's Cyborgs",
	icon = "img/icon.png",
	version = "1.0.0",
	modApiVersion = "2.8.3",
	gameVersion = "1.2.88",
    dependencies = {
        modApiExt = "1.17",
		memedit = "1.0.1",
    }
}

function mod:init()
	--Libs
	require(self.scriptPath.."/libs/customAnim")
	require(self.scriptPath.."/libs/weaponArmed")

	--Assets
	require(self.scriptPath.."assets")

	--Misc
	--require(self.scriptPath .."achievements")

	--Weapons
	require(self.scriptPath.."/weapons/scorpion_attack")
	require(self.scriptPath.."/weapons/bouncer_attack")
	--require(self.scriptPath.."/weapons/bouncer_attack_BU") --this one is functional but has wacky delays
	require(self.scriptPath.."/weapons/burrower_attack")

	--Pawns
	require(self.scriptPath .."pawns")
end

function mod:load(options, version)
	--require(self.scriptPath .."weaponPreview/api"):load() --old, taken from NN
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
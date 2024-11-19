local mod = {
	id = "truelch_Cyborg_Squad",
	name = "Truelch's Cyborgs",
	icon = "img/icon.png",
	version = "1.1.1",
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
	require(self.scriptPath.."achievements")

	-- FMW ----->
	--modapi already defined
	self.FMW_hotkeyConfigTitle = "Mode Selection Hotkey" -- title of hotkey config in mod config
	self.FMW_hotkeyConfigDesc = "Hotkey used to open and close firing mode selection." -- description of hotkey config in mod config

	--init FMW
	require(self.scriptPath.."fmw/FMW"):init()

	--FMW weapons
	require(self.scriptPath.."/weapons/bouncerFMW")
	-- <----- FMW

	--Weapons
	require(self.scriptPath.."/weapons/scorpion_attack")
	require(self.scriptPath.."/weapons/bouncer_attack")
	require(self.scriptPath.."/weapons/burrower_attack")

	--Pawns
	require(self.scriptPath.."pawns")
end

function mod:load(options, version)
	--FMW
	require(self.scriptPath.."fmw/FMW"):load()
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
		self.resourcePath.."img/icon.png"
	)
end

return mod
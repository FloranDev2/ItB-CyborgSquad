-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-- add assets from our mod so the game can find them.

local iconPath = path .."img/weapons/"

local files = {
	"truelch_scorpion_attack.png",
	"truelch_bouncer_attack.png",
	"truelch_burrower_attack.png"
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/weapons/".. file, iconPath .. file)
end


truelch_ScorpionAttack = Skill:new{
	--Infos
	Name = "Entangling Spinneret",
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it",
	Class = "TechnoVek",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2, --2
	UpgradeCost = {}, --{2,2}

	--Gameplay
	Damage = 1,
	ZoneTargeting = ZONE_DIR,

	--Art
	Icon = "weapons/truelch_scorpion_attack.png",
	LaunchSound = "/enemy/burnbug_2/attack_launch",

	--Tip image
	TipImage = {
		Unit = Point(2,3),
	}
}

Weapon_Texts.truelch_ScorpionAttack_Upgrade1 = "Extended spinneret"
Weapon_Texts.truelch_ScorpionAttack_Upgrade2 = "+1 Damage"

truelch_ScorpionAttack_A = truelch_ScorpionAttack:new{
	UpgradeDescription = "Can target any adjacent target.",
}

truelch_ScorpionAttack_B = truelch_ScorpionAttack:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2,
}

truelch_ScorpionAttack_AB = truelch_ScorpionAttack:new{
	Damage = 2,
}

function truelch_ScorpionAttack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
		
	return ret
end
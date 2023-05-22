truelch_ScorpionAttack = Skill:new{
	--Infos
	Name = "Entangling Spinneret",
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it",
	Class = "TechnoVek",
	Icon = "weapons/truelch_scorpion_attack.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2,2},

	--Gameplay
	Damage = 1,
	ZoneTargeting = ZONE_DIR,

	--Art
	--LaunchSound = "/enemy/burnbug_2/attack_launch",

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

function truelch_ScorpionAttack:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		local curr = Point(point + DIR_VECTORS[dir])
		ret:push_back(curr)
	end
	
	return ret
end

function truelch_ScorpionAttack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
		


	return ret
end
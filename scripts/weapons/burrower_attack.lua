truelch_BurrowerAttack = Skill:new{
	--Infos
	Name = "Bladed Carapace",
	Description = "Damages an adjacent target. Pushes tiles on the left and right of the target.",
	Class = "TechnoVek",
	Icon = "weapons/truelch_burrower_attack.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2,2},

	--Gameplay
	--PathSize = 1, --what does that mean?
	--ZoneTargeting = ZONE_DIR, --what does that mean?
	Damage = 2,

	Crack = false,
	Confuse = false,

	--Art
	LaunchSound = "",
	SoundBase = "/enemy/burrower_1/",
	Explosion = "SwipeClaw2",

	--Tip image
	TipImage = {
		Unit = Point(2,3),
	}
}

Weapon_Texts.truelch_BurrowerAttack_Upgrade1 = "Crack"
Weapon_Texts.truelch_BurrowerAttack_Upgrade2 = "Confuse"

truelch_BurrowerAttack_A = truelch_BurrowerAttack:new{
	UpgradeDescription = "Crack the previous tile it was standing one before the move.",
	Crack = true,
}

truelch_BurrowerAttack_B = truelch_BurrowerAttack:new{
	UpgradeDescription = "Confuses hit enemies.",
	Confuse = true,
}

truelch_BurrowerAttack_AB = truelch_BurrowerAttack:new{
	Crack = true,
	Confuse = true,
}

function truelch_BurrowerAttack:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		local curr = Point(point + DIR_VECTORS[dir])
		ret:push_back(curr)
	end
	
	return ret
end

function truelch_BurrowerAttack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	--Center
	local dmg1 = SpaceDamage(p2, self.Damage)
	dmg1.sSound = self.SoundBase.."attack"	
	ret:AddDamage(dmg1)

	--Right
	local dir2 = DIR_VECTORS[(direction + 1)% 4]
	local dmg2 = SpaceDamage(p2 + dir2, 0, dir2)
	ret:AddDamage(dmg2)

	--Left
	local dir3 = DIR_VECTORS[(direction + 1)% 4]
	local dmg3 = SpaceDamage(p2 + dir3, 0, dir3)
	ret:AddDamage(dmg3)

	return ret
end
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

	--TC
	TwoClick = true,

	--Gameplay
	Range = 1,
	Damage = 1,
	--ZoneTargeting = ZONE_DIR,

	--Art
	--LaunchSound = "/enemy/burnbug_2/attack_launch",

	--Tip image
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy = Point(2,2),
		Second_Click = Point(3,1),



		CustomPawn = "truelch_ScorpionMech"
	},
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

function truelch_ScorpionAttack:IsControllable(p2)

	if not Board:IsPawnSpace(p2) then
		return false
	end

	local pawn = Board:GetPawn(p2)
		
	if pawn:IsGuarding() and not pawn:IsBurrower() then
		return false
	end
	
	if not pawn:IsPowered() then
		return false
	end
	
	if pawn:IsFrozen() then
		return false
	end
	
	if pawn:GetType() == "Snowmine1" or pawn:GetType() == "VIP_Truck" then
		return true
	end
	
	if (pawn:GetMoveSpeed() ~= 0 or pawn:IsGrappled()) and
		pawn:GetBaseMove() ~= 0 then
		return true
	end

	return false
end

--Old
--[[
function truelch_ScorpionAttack:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		local curr = Point(point + DIR_VECTORS[dir])
		ret:push_back(curr)
	end
	
	return ret
end
]]

function truelch_ScorpionAttack:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		for range = 1, self.Range do
			local curr = point + DIR_VECTORS[dir]*range
			if self:IsControllable(curr) then
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end

function truelch_ScorpionAttack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2,0)
	if Board:IsPawnSpace(p2) then
		damage.sImageMark = "combat/icons/icon_mind_glow.png"
	else
		damage.sImageMark = "combat/icons/icon_mind_off_glow.png"
	end
	ret:AddDamage(damage)
	return ret
end


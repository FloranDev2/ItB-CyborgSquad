truelch_BouncerAttack = Skill:new{
	--Infos
	Name = "Entangling Spinneret",
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it",
	Class = "TechnoVek",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2,2},

	--TC
	TwoClick = true,

	--Gameplay
	SelfDamage = 1,
	Armored = false,
	Range = 2,
}

--I might consider not targetting empty spaces
--What about mountains?
function truelch_BouncerAttack:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[i]
	--	if Board:IsPawnSpace(curr) and not Board:GetPawn(curr):IsGuarding() then
			--local empty_spaces = self:GetSecondTargetArea(point, curr)
			--if not empty_spaces:empty() then
				ret:push_back(curr)
			--end
		--end
	end
	
	return ret
end

Weapon_Texts.truelch_ScorpionAttack_Upgrade1 = "Sweeping horns"
Weapon_Texts.truelch_ScorpionAttack_Upgrade2 = "Reinforced carapace"

truelch_BouncerAttack_A = truelch_BouncerAttack:new{
	UpgradeDescription = "Can target any adjacent target.",
}

truelch_BouncerAttack_B = truelch_BouncerAttack:new{
	UpgradeDescription = "Can target any adjacent target.",
}

truelch_BouncerAttack_AB = truelch_BouncerAttack:new{
	UpgradeDescription = "Can target any adjacent target.",
}

function truelch_BouncerAttack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2,0)
	local direction = GetDirection(p2 - p1)

	if Board:IsPawnSpace(p2) and not Board:GetPawn(p2):IsGuarding() then
	
		for i = 1, self.Range do
			local curr = p2 + DIR_VECTORS[direction]*i
			if Board:IsValid(curr) and Board:IsBlocked(curr, PATH_FLYER) then
				local block_image = SpaceDamage(curr,0)
				block_image.sImageMark = "advanced/combat/icons/icon_throwblocked_glow.png"
				ret:AddDamage(block_image)
			end
		end
	
		local empty_spaces = self:GetSecondTargetArea(p1, p2)
		if not empty_spaces:empty() then
			damage.sImageMark = "advanced/combat/throw_"..GetDirection(p2-p1)..".png"
			ret:AddMelee(p1, damage)
			return ret			
		end
	end
	
	damage.sImageMark = "advanced/combat/throw_"..GetDirection(p2-p1).."_off.png"
	ret:AddDamage(damage)
	return ret
end

function truelch_BouncerAttack:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)
	
	if not Board:IsPawnSpace(p2) or Board:GetPawn(p2):IsGuarding() then
		return ret
	end
	
	for i = 1, self.Range do
		local curr = p2 + DIR_VECTORS[direction]*i
		if Board:IsValid(curr) and not Board:IsBlocked(curr, PATH_FLYER) then
			ret:push_back(curr)
		end
	end
	
	return ret
end

function truelch_BouncerAttack:GetFinalEffect(p1,p2,p3)
	local ret = SkillEffect()	
	
	local damage = SpaceDamage(p2,0)
	damage.sImageMark = "advanced/combat/throw_"..GetDirection(p2-p1)..".png"
	ret:AddMelee(p1, damage)
	ret:AddBounce(p1,3)
	ret:AddBounce(p2,-4)
	local move = PointList()
	move:push_back(p2)
	move:push_back(p3)
	ret:AddLeap(move,FULL_DELAY)
	ret:AddDamage(SpaceDamage(p3,self.Damage))
	ret:AddBurst(p3,"Emitter_Crack_Start2",DIR_NONE)
	ret:AddBounce(p3,4)

	return ret
end


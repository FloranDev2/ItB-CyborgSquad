truelch_BouncerAttack = Skill:new{
	--Infos
	Name = "Entangling Spinneret",
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it",
	Class = "TechnoVek",
	Icon = "weapons/truelch_bouncer_attack.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2,2},

	--TC
	TwoClick = true,

	--Gameplay
	Damage = 1, --if there's no pawn on the end tile
	SelfDamage = 1,
	Armored = false,
	Range = 2,

	--Tip Image
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(2,0),		
		Target = Point(2,2),
		Second_Click = Point(2,0),

		--Enemy3 = Point(1,3),
		--Second_Origin = Point(2,3),
		--Second_Target = Point(1,3),
		--What's the second click for the second attack in the tip image?

		--Enemy_Damaged = Point(2,2),

		CustomPawn = "truelch_BouncerMech"
	}
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

Weapon_Texts.truelch_BouncerAttack_Upgrade1 = "Sweeping horns"
Weapon_Texts.truelch_BouncerAttack_Upgrade2 = "Reinforced carapace"

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
		--if Board:IsValid(curr) and not Board:IsBlocked(curr, PATH_FLYER) then
		ret:push_back(curr)
		--end
	end
	
	return ret
end

function truelch_BouncerAttack:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()

	local pawn1 = Board:GetPawn(p2)
	local pawn2 = Board:GetPawn(p3)

	local selfDamage = 0

	local dmg1 = self.Damage
	if pawn2 ~= nil then
		dmg1 = pawn2:GetHealth()
		if pawn2:IsArmor() then
			dmg1 = dmg1 + 1
		end

		--Self damage
		selfDamage = self.SelfDamage
	end

	local dmg2 = pawn1
	if pawn1 ~= nil then
		dmg2 = pawn1:GetHealth()
		if pawn1:IsArmor() then
			dmg2 = dmg2 + 1
		end
	end	

	--Self push + self damage
	--local selfDam = SpaceDamage(p1, selfDamage, GetDirection(p1 - p2))
	--ret:AddDamage(selfDam)

	if pawn2 ~= nil then
		--Throw at enemy
		--damage to target (we do that before so both pawns aren't in the same pos)
		local spaceDamage2 = SpaceDamage(p3, dmg2)
		ret:AddDamage(SpaceDamage(p3, dmg2))
		
		local spaceDamage1 = SpaceDamage(p2, 0)
		spaceDamage1.sImageMark = "advanced/combat/throw_"..GetDirection(p2 - p1)..".png"
		ret:AddMelee(p1, spaceDamage1)
		ret:AddBounce(p1, 3)
		ret:AddBounce(p2, -4)
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddLeap(move, FULL_DELAY)
		--ret:AddDamage(SpaceDamage(p3, self.Damage))
		ret:AddDamage(SpaceDamage(p3, dmg1))
		ret:AddBurst(p3, "Emitter_Crack_Start2", DIR_NONE)
		ret:AddBounce(p3, 4)
	else
		--Otherwise, like a regular punch with 1 damage
		local direction = GetDirection(p2 - p1)
		local spaceDamage = SpaceDamage(p2, self.Damage, direction)
		spaceDamage.sAnimation = "SwipeClaw2"
		ret:AddMelee(p2 - DIR_VECTORS[direction], spaceDamage)
	end

	--Self push + self damage
	local selfDam = SpaceDamage(p1, selfDamage, GetDirection(p1 - p2))
	ret:AddDamage(selfDam)

	return ret
end


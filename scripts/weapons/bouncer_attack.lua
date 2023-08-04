local tipIndex

truelch_BouncerAttack = Skill:new{
	--Infos
	Name = "Cyborg Horn",
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it",
	Class = "TechnoVek",
	Icon = "weapons/truelch_bouncer_attack.png",

	--Bouncer
	LaunchSound = "",
	SoundBase = "/enemy/bouncer_1",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 2, 1 },

	--TC
	TwoClick = true,

	--Gameplay
	Damage = 1, --if there's no pawn on the end tile
	SelfDamage = 1,
	Range = 2,

	Sweep = false,

	--Tip Image
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 2),
		Enemy2 = Point(2, 0),		
		Target = Point(2, 2),
		Second_Click = Point(2, 0),

		--Enemy3 = Point(1, 3),
		--Second_Origin = Point(2, 3),
		--Second_Target = Point(1, 3),
		--What's the second click for the second attack in the tip image?

		--Enemy_Damaged = Point(2, 2),

		CustomPawn = "truelch_BouncerMech"
	}
}

--I might consider not targetting empty spaces
--What about mountains?
function truelch_BouncerAttack:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[i]
		ret:push_back(curr)
	end
	
	return ret
end

Weapon_Texts.truelch_BouncerAttack_Upgrade1 = "Sweeping horns"
Weapon_Texts.truelch_BouncerAttack_Upgrade2 = "Reinforced carapace"

truelch_BouncerAttack_A = truelch_BouncerAttack:new{
	UpgradeDescription = "Can target any adjacent target.",
	Sweep = true,
}

truelch_BouncerAttack_B = truelch_BouncerAttack:new{
	UpgradeDescription = "The Mech doesn't take self damage anymore.",
	SelfDamage = 0,
}

truelch_BouncerAttack_AB = truelch_BouncerAttack:new{
	Sweep = true,
	SelfDamage = 0,
}

--[[
function truelch_BouncerAttack:IsTwoClickException(p1, p2)
	if not Board:IsPawnSpace(p2) then
		return true
	end
	
	return false
end
]]

--p is p2 or the adjacent point when the weapon is upgraded
--[[
function truelch_BouncerAttack:ExtGetSE(p)
	if ()
end
]]

function truelch_BouncerAttack:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	--local damage = SpaceDamage(p2, 0)
	local damage = SpaceDamage(p2, 0)
	local direction = GetDirection(p2 - p1)

	if Board:IsPawnSpace(p2) and not Board:GetPawn(p2):IsGuarding() then	
		for i = 1, self.Range do
			local curr = p2 + DIR_VECTORS[direction] * i
			if Board:IsValid(curr) and Board:IsBlocked(curr, PATH_FLYER) then
				local block_image = SpaceDamage(curr, 0)
				block_image.sImageMark = "advanced/combat/icons/icon_throwblocked_glow.png"
				ret:AddDamage(block_image)
			end
		end
	
		local empty_spaces = self:GetSecondTargetArea(p1, p2)
		if not empty_spaces:empty() then
			--damage.sImageMark = "advanced/combat/throw_"..GetDirection(p2 - p1)..".png"
			damage.sImageMark = "advanced/combat/throw_"..direction..".png"
			ret:AddMelee(p1, damage)
			return ret
		end
	end
	
	damage.sImageMark = "advanced/combat/throw_"..direction.."_off.png"
	ret:AddDamage(damage)
	return ret
end

function truelch_BouncerAttack:BACK_UP_GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	--local damage = SpaceDamage(p2, 0)
	local damage = SpaceDamage(p2, 0)
	local direction = GetDirection(p2 - p1)

	if Board:IsPawnSpace(p2) and not Board:GetPawn(p2):IsGuarding() then	
		for i = 1, self.Range do
			local curr = p2 + DIR_VECTORS[direction] * i
			if Board:IsValid(curr) and Board:IsBlocked(curr, PATH_FLYER) then
				local block_image = SpaceDamage(curr, 0)
				block_image.sImageMark = "advanced/combat/icons/icon_throwblocked_glow.png"
				ret:AddDamage(block_image)
			end
		end
	
		local empty_spaces = self:GetSecondTargetArea(p1, p2)
		if not empty_spaces:empty() then
			--damage.sImageMark = "advanced/combat/throw_"..GetDirection(p2 - p1)..".png"
			damage.sImageMark = "advanced/combat/throw_"..direction..".png"
			ret:AddMelee(p1, damage)
			return ret
		end
	end
	
	damage.sImageMark = "advanced/combat/throw_"..direction.."_off.png"
	ret:AddDamage(damage)
	return ret
end

function truelch_BouncerAttack:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)
	
	if Board:IsPawnSpace(p2) and Board:GetPawn(p2):IsGuarding() then
		return ret
	end
	
	for i = 1, self.Range do
		local curr = p2 + DIR_VECTORS[direction] * i
		ret:push_back(curr)
	end
	
	return ret
end

function truelch_BouncerAttack:BACK_UP_GetSecondTargetArea(p1, p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)
	
	if not Board:IsPawnSpace(p2) or Board:GetPawn(p2):IsGuarding() then
		return ret
	end
	
	for i = 1, self.Range do
		local curr = p2 + DIR_VECTORS[direction] * i
		ret:push_back(curr)
	end
	
	return ret
end

function truelch_BouncerAttack:FinalAttackCommon(ret, customP2, customP3, dir, pawn2, pawn3, dmg)
	--Bounce and burst
	ret:AddBurst(customP3, "Emitter_Crack_Start2", DIR_NONE)
	ret:AddBounce(customP3, 4)

	--Throw effect
	local throwEffect = SpaceDamage(customP2, 0)
	throwEffect.sImageMark = "advanced/combat/throw_"..dir..".png"
	ret:AddDamage(throwEffect)
	ret:AddBounce(customP2, -4)

	--Leap
	local move = PointList()
	move:push_back(customP2)
	move:push_back(customP3)
	ret:AddLeap(move, FULL_DELAY)

	--P2 Damage
	ret:AddDamage(SpaceDamage(customP3, dmg))
end

function truelch_BouncerAttack:FinalAttack(ret, p1, customP2, customP3, dir, dirback)
	--LOG("--- FinalAttack ---")
	local pawn2 = Board:GetPawn(customP2)
	local pawn3 = Board:GetPawn(customP3)

	local selfDamage = 0

	local dmg2 = self.Damage
	if pawn3 ~= nil then
		dmg2 = pawn3:GetHealth()
		if pawn3:IsArmor() then
			dmg2 = dmg2 + 1
		end

		--Self damage
		selfDamage = self.SelfDamage
	end

	local dmg3 = self.Damage
	if pawn2 ~= nil then
		dmg3 = pawn2:GetHealth()
		if pawn2:IsArmor() then
			dmg3 = dmg3 + 1
		end
	end

	local selfDam = SpaceDamage(p1, selfDamage, dirback)
	selfDam.sAnimation = "airpush_"..dirback
	ret:AddDamage(selfDam)

	--LOG("type(pawn3): " .. type(pawn3) .. ", if pawn3 ~= nil then:")

	if pawn3 ~= nil and pawn2 ~= nil then --attempt to compare with number
		--LOG("-> pawn3 ~= nil")
		if dmg2 < dmg3 then
			self:FinalAttackCommon(ret, customP2, customP3, dir, pawn2, pawn3, dmg2)
		else
			self:FinalAttackCommon(ret, customP2, customP3, dir, pawn2, pawn3, dmg3)
		end

	else
		--LOG("Else")
		--Otherwise, like a regular punch with 1 damage
		local spaceDamage = SpaceDamage(customP2, self.Damage, dir)
		spaceDamage.sAnimation = "SwipeClaw2"
		spaceDamage.sSound = self.SoundBase.."/attack"
		ret:AddDamage(spaceDamage)
	end

	--LOG("End")
end

function truelch_BouncerAttack:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local dirback = GetDirection(p1 - p2)

	ret:AddBounce(p1, 3)
	self:FinalAttack(ret, p1, p2, p3, dir, dirback)

	if self.Sweep then
		local offset1 = DIR_VECTORS[(dir-1)%4]
		local offset2 = DIR_VECTORS[(dir+1)%4]
		self:FinalAttack(ret, p1, p2 + offset1, p3 + offset1, dir, dirback)
		self:FinalAttack(ret, p1, p2 + offset2, p3 + offset2, dir, dirback)
	end

	return ret
end
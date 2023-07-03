--[[
It seems that the self damage doesn't work
I also need to add the ability to attack when there's no pawn.
(useful to move using the push back or also damage mountains)

I launched a boss with 3 remaining HP into a vek with 2 remaining HP and it killed the boss too.
]]



local tipIndex

truelch_BouncerAttack = Skill:new{
	--Infos
	Name = "Entangling Spinneret",
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
	UpgradeCost = {2,2},

	--TC
	TwoClick = true,

	--Gameplay
	Damage = 1, --if there's no pawn on the end tile
	SelfDamage = 1,
	Range = 2,

	Sweep = false,
	Armored = false,

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
	Sweep = true,
}

truelch_BouncerAttack_B = truelch_BouncerAttack:new{
	UpgradeDescription = "The Mech gains armored.",
	Armored = true,
}

truelch_BouncerAttack_AB = truelch_BouncerAttack:new{
	Sweep = true,
	Armored = true,
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


--- FINAL EFFECT ---
function truelch_BouncerAttack:truelch_FinalAttack(ret, p1, customP2, customP3, dir, dirback)

	LOG("Custom - A")

	local pawn2 = Board:GetPawn(customP2)

	LOG("Custom - B")

	local pawn3 = Board:GetPawn(customP3)

	LOG("Custom - C")

	local selfDamage = 0

	LOG("Custom - D")

	local dmg2 = self.Damage
	LOG("Custom - E")
	if pawn3 ~= nil then
		LOG("Custom - E1")
		dmg2 = pawn3:GetHealth()
		LOG("Custom - E2")
		if pawn3:IsArmor() then
			dmg2 = dmg2 + 1
			LOG("Custom - E3")
		end

		--Self damage
		selfDamage = self.SelfDamage
		LOG("Custom - E4")
	end

	LOG("Custom - F")

	local dmg3 = pawn2

	LOG("Custom - G")

	if pawn2 ~= nil then
		dmg3 = pawn2:GetHealth()
		if pawn2:IsArmor() then
			dmg3 = dmg3 + 1
		end
	end	

	--Self push + self damage (DO THAT MULTIPLE TIME?)
	local selfDam = SpaceDamage(p1, 0, dirback)
	selfDam.sAnimation = "airpush_"..dirback
	ret:AddDamage(selfDam)

	if pawn3 ~= nil then
		local spaceDamage2 = SpaceDamage(customP2, 0)
		spaceDamage2.sImageMark = "advanced/combat/throw_"..dir..".png"
		ret:AddDamage(spaceDamage2)
		--ret:AddBounce(p1, 3)
		ret:AddBounce(customP2, -4)

		--Move
		local move = PointList()
		move:push_back(customP2)
		move:push_back(customP3)
		ret:AddLeap(move, NO_DELAY) --test

		--P3 damage
		ret:AddDamage(SpaceDamage(customP3, dmg3))
		ret:AddBurst(customP3, "Emitter_Crack_Start2", DIR_NONE)
		ret:AddBounce(customP3, 4)
	else
		--Otherwise, like a regular punch with 1 damage
		local spaceDamage = SpaceDamage(customP2, self.Damage, dir)
		spaceDamage.sAnimation = "SwipeClaw2"
		spaceDamage.sSound = self.SoundBase.."/attack"
		ret:AddDamage(spaceDamage)
	end

	return ret
end


--[[
Bugs:
- When you launch a little enemy (1 HP) on a big enemy (3 HP), the big enemy will take whole damage.
  The other way around works properly though.
]]
function truelch_BouncerAttack:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()

	LOG("A")

	local dir = GetDirection(p2 - p1)

	LOG("B")

	local dirback = GetDirection(p1 - p2)

	LOG("C")

	ret:AddBounce(p1, 3)

	LOG("D")

	self:truelch_FinalAttack(ret, p1, p2, p3, dir, dirback)

	LOG("E")

	if self.Sweep then
		LOG("F")
		local offset1 = DIR_VECTORS[(dir-1)%4]
		local offset2 = DIR_VECTORS[(dir+1)%4]
		self:truelch_FinalAttack(ret, p1, p2 + offset1, p3 + offset1, dir, dirback)
		self:truelch_FinalAttack(ret, p1, p2 + offset2, p3 + offset2, dir, dirback)
	end

	LOG("G")

	return ret
end


function truelch_FinalAttackOld(ret, customP2, customP3)
	local pawn2 = Board:GetPawn(p2)
	local pawn3 = Board:GetPawn(p3)

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

	local dmg3 = pawn2
	if pawn2 ~= nil then
		dmg3 = pawn2:GetHealth()
		if pawn2:IsArmor() then
			dmg3 = dmg3 + 1
		end
	end	

	--Self push + self damage
	local dirback = GetDirection(p1 - p2)
	local selfDam = SpaceDamage(p1, 0, dirback)
	selfDam.sAnimation = "airpush_"..dirback
	ret:AddDamage(selfDam)

	if pawn3 ~= nil then
		--Throw at enemy
	
		--P2 damage
		local spaceDamage2 = SpaceDamage(p2, 0)
		spaceDamage2.sImageMark = "advanced/combat/throw_"..GetDirection(p2 - p1)..".png"
		--ret:AddMelee(p1, spaceDamage1)
		ret:AddDamage(spaceDamage2) --works better
		ret:AddBounce(p1, 3)
		ret:AddBounce(p2, -4)

		--Move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddLeap(move, FULL_DELAY)

		--P3 damage
		--ret:AddDamage(SpaceDamage(p3, self.Damage))
		ret:AddDamage(SpaceDamage(p3, dmg3)) --works better
		ret:AddBurst(p3, "Emitter_Crack_Start2", DIR_NONE)
		ret:AddBounce(p3, 4)
	else
		--Otherwise, like a regular punch with 1 damage
		local direction = GetDirection(p2 - p1)
		local spaceDamage = SpaceDamage(p2, self.Damage, direction)
		spaceDamage.sAnimation = "SwipeClaw2"
		spaceDamage.sSound = self.SoundBase.."/attack"
		--ret:AddMelee(p2 - DIR_VECTORS[direction], spaceDamage)
		ret:AddDamage(spaceDamage) --works better
	end

	return ret
end
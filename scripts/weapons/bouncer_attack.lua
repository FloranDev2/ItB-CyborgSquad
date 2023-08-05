local tipIndex
local selfDmgCond

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
		--What's the second click for the second attack in the tip image? It doesn't exist... ugh

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

function truelch_BouncerAttack:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2, 0)
	local direction = GetDirection(p2 - p1)

	if Board:IsPawnSpace(p2) and not Board:GetPawn(p2):IsGuarding() then	
		for i = 1, self.Range do
			local curr = p2 + DIR_VECTORS[direction] * i
			if Board:IsValid(curr) and Board:IsBlocked(curr, PATH_FLYER) then
				local block_image = SpaceDamage(curr, 0)
				block_image.sImageMark = "advanced/combat/icons/icon_throwblocked_glow.png" --TODO: we actually want to throw there
				ret:AddDamage(block_image)
			end
		end
	
		local empty_spaces = self:GetSecondTargetArea(p1, p2)
		if not empty_spaces:empty() then
			damage.sImageMark = "advanced/combat/throw_"..direction..".png"
			ret:AddMelee(p1, damage)
			return ret
		end
	end
	
	--With the old weapon, we arrive here if there are no empty spaces
	--But actually, we'd disable throw at the opposite condition: if all spaces are empty, we can't throw!
	damage.sImageMark = "advanced/combat/throw_"..direction.."_off.png" --TODO
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

------------------------------------------------------------------------------------------

--[[
Need to take account of:
- Ice
- Passive that makes allied mechs invulnerable
- What about pawns that leaves a corpse???
  -> Disable throwing a Mech or any pawn that leaves a corpse I guess
- ACID????
]]
function truelch_BouncerAttack:ComputeDamage(customP2, customP3)
	--LOG("ComputeDamage - A")

	local pawn2 = Board:GetPawn(customP2)
	local pawn3 = Board:GetPawn(customP3)

	--LOG("ComputeDamage - B")

	local dmg2 = self.Damage
	if pawn3 ~= nil then
		dmg2 = pawn3:GetHealth()
		if pawn3:IsArmor() then
			dmg2 = dmg2 + 1
		end
	end

	--LOG("ComputeDamage - C")

	local dmg3 = self.Damage
	if pawn2 ~= nil then
		dmg3 = pawn2:GetHealth()
		if pawn2:IsArmor() then
			dmg3 = dmg3 + 1
		end
	end

	--LOG("ComputeDamage - D")

	if pawn3 ~= nil and pawn2 ~= nil then
		selfDmgCond = true --THIS! DON'T FORGET ABOUT THIS!
		if dmg2 < dmg3 then
			--LOG("ComputeDamage -> return dmg2")
			return dmg2
		else
			--LOG("ComputeDamage -> return dmg3")
			return dmg3
		end
	else
		--LOG("ComputeDamage -> return nil")
		return nil
	end
end

function truelch_BouncerAttack:PushAttack(ret, customP2, dir)
	local spaceDamage = SpaceDamage(customP2, self.Damage, dir)
	spaceDamage.sAnimation = "SwipeClaw2"
	spaceDamage.sSound = self.SoundBase.."/attack"
	ret:AddDamage(spaceDamage)
end

function truelch_BouncerAttack:ThrowAttack(ret, customP2, customP3, dir, isDelay)
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
	local delay = NO_DELAY
	if isDelay then
		delay = FULL_DELAY
	end
	ret:AddLeap(move, delay)
end

function truelch_BouncerAttack:GetFinalEffect(p1, p2, p3)
	LOG("GetFinalEffect - A")
	--Vars init
	selfDmgCond = false --THIS!

	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local dirback = GetDirection(p1 - p2)

	--Offsets
	local offset1 = DIR_VECTORS[(dir-1)%4] --B
	local offset2 = DIR_VECTORS[(dir+1)%4] --C

	--Adjacent to p2 (sweep)
	local customP2B = p2 + offset1 --B
	local customP2C = p2 + offset2 --C

	--Adjacent to p3 (sweep)
	local customP3B = p3 + offset1 --B
	local customP3C = p3 + offset2 --C

	--Damages for throw. If nil, the throw is not possible.
	local dmgA = self:ComputeDamage(p2, p3)
	local dmgB = self:ComputeDamage(customP2B, customP3B)
	local dmgC = self:ComputeDamage(customP2C, customP3C)

	--Pawns
	local pawnA2 = Board:GetPawn(p2)
	local pawnA3 = Board:GetPawn(p3)
	local pawnB2 = Board:GetPawn(customP2B)
	local pawnB3 = Board:GetPawn(customP3B)
	local pawnC2 = Board:GetPawn(customP2C)
	local pawnC3 = Board:GetPawn(customP3C)

	--Delays
	--We need to find the last delay (for example, C could be a regular push while A and B are throws)
	--dmgA, B and C returned by ComputeDamage are nil if the attack should be a push (pawn2 or pawn3 don't exist (or both))
	local delayA = false
	local delayB = false
	local delayC = false

	if dmgC ~= nil then
		delayC = true
	elseif dmgB ~= nil then
		delayB = true
	elseif dmgA ~= nil then
		delayA = true
	end

	--Self damage and push back	
	ret:AddBounce(p1, 3)
	local selfDmg = 0
	if selfDmgCond then
		selfDmg = self.SelfDamage
	end
	local selfDamSD = SpaceDamage(p1, selfDmg, dirback)
	selfDamSD.sAnimation = "airpush_"..dirback
	ret:AddDamage(selfDamSD)

	--Do all push attacks (when applicable)	
	if dmgA == nil then
		self:PushAttack(ret, p2, dir) --A
	end
	if self.Sweep then
		if dmgB == nil then
			self:PushAttack(ret, customP2B, dir) --B
		end	
		if dmgC == nil then
			self:PushAttack(ret, customP2C, dir) --C
		end
	end

	--Do all throw attacks (when applicable)
	if dmgA ~= nil then
		self:ThrowAttack(ret, p2, p3, dir, isDelay) --A
	end
	if self.Sweep then
		if dmgB ~= nil then
			self:ThrowAttack(ret, customP2B, customP3B, dir, isDelay) --B
		end
		if dmgC ~= nil then
			self:ThrowAttack(ret, customP2C, customP3C, dir, isDelay) --C
		end
	end

	--Final damages for throw attacks (after delay)
	if dmgA ~= nil then
		ret:AddDamage(SpaceDamage(p3, dmgA)) --A
	end
	if self.Sweep then
		if dmgB ~= nil then
			ret:AddDamage(SpaceDamage(customP3B, dmgB)) --B
		end
		if dmC ~= nil then
			ret:AddDamage(SpaceDamage(customP3C, dmgC)) --C
		end
	end

	--Return
	return ret
end
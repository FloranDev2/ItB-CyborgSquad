-- --- IMPORT / FMW MANDATORY STUFF --- --
local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

local fmw = require(path.."fmw/api")

modApi:appendAsset("img/modes/icon_bouncer_normal_mode.png", resources.."img/modes/icon_bouncer_normal_mode.png")
modApi:appendAsset("img/modes/icon_bouncer_sweep_mode.png",  resources.."img/modes/icon_bouncer_sweep_mode.png")

-- --- VARS --- --
local tipIndex
local selfDmgCond

-- --- NORMAL MODE --- --
--Single target push / throw
truelch_BouncerMode1 = {
	aFM_name = "Normal Mode",
	aFM_desc = "Single target mode",
	aFM_icon = "img/modes/icon_bouncer_normal_mode.png",
	Sweep = false,
}

CreateClass(truelch_BouncerMode1)

-- --- SWEEP MODE --- --
-- AoE target push / throw
truelch_BouncerMode2 = truelch_BouncerMode1:new{
	aFM_name = "Napalm Shell",
	aFM_desc = "Sweep that attacks 3 targes in front",
	aFM_icon = "img/modes/icon_bouncer_sweep_mode.png",
	Sweep = true,
}

truelch_BouncerFMW = aFM_WeaponTemplate:new{
	--Infos and art
	Name = "Cyborg Horn",
	Description = "Throw a unit into another, each unit taking an amount of damage equal to the hit points of the other, and self-damage the Mech.\nIf there is no enemy in the destination, damage and push the target instead.\nPush the Mech backwards in any case.\nThrow range: 2.",
	Class = "TechnoVek",
	Icon = "weapons/truelch_bouncer_attack.png",
	LaunchSound = "", --unnecessary
	SoundBase = "/enemy/bouncer_1",

	--Gameplay
	Damage = 1, --if there's no pawn on the end tile
	SelfDamage = 1,
	Range = 2,

	--Upgrades
	Upgrades = 2,
	UpgradeCost = { 2, 1 },

	--TC
    TwoClick = true,

	--FMW
	aFM_ModeList = { "truelch_BouncerMode1" }, --only the single target mode
	aFM_ModeSwitchDesc = "Click to change attack mode.",

	--TipImage
	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 2),
		Enemy2 = Point(2, 0),
		Enemy3 = Point(1, 2),
		Target = Point(2, 2),
		Building = Point(3, 2),
		Second_Click = Point(2, 0),
		CustomPawn = "truelch_BouncerMech",
	}
	--To debug sweep
	--[[
	TipImage = {
		Unit = Point(2, 3),

		Enemy  = Point(1, 2),
		Enemy2 = Point(2, 2),
		Enemy3 = Point(3, 2),

		Enemy5 = Point(1, 0),
		Enemy6 = Point(2, 0),
		Enemy7 = Point(3, 0),

		Target = Point(2, 2),
		Second_Click = Point(2, 0),

		--Building = Point(3, 2),
		CustomPawn = "truelch_BouncerMech",
	}
	]]
}

-- --- FUNCTIONS --- --
local function HasSquadNetworkShield()
	for i = 0, 2 do
		local mech = Board:GetPawn(i)
		if mech ~= nil then --shouldn't be necessary, but we never know...
			local weapons = mech:GetPoweredWeapons()
			for j = 1, 2 do
				if weapons[j] == "Passive_PlayerTurnShield" then
					return true
				end				
			end
		end
	end
	return false
end

local function IsEdge(p1, p2)
	local direction = GetDirection(p2 - p1)
	local testP = p2 + DIR_VECTORS[direction]
	return not Board:IsValid(testP)
end

local kindaCorpses =
{
	"lmn_SequoiaBoss",
	"lmn_SequoiaBoss2"
}

local function IsKindaCorpse(pawn)	
	local pawnType = pawn:GetType()
	for _, elem in pairs(kindaCorpses) do
		if pawnType == elem then
			return true
		end
	end
	return false
end

Weapon_Texts.truelch_BouncerFMW_Upgrade1 = "Sweeping horns"
Weapon_Texts.truelch_BouncerFMW_Upgrade2 = "Reinforced carapace"

truelch_BouncerFMW_A = truelch_BouncerFMW:new{
	UpgradeDescription = "Can target any adjacent target.", --Maybe improve this description
	aFM_ModeList = { "truelch_BouncerMode1", "truelch_BouncerMode2" }, --Replaces Sweep = true
}

truelch_BouncerFMW_B = truelch_BouncerFMW:new{
	UpgradeDescription = "The Mech doesn't take self-damage anymore.",
	SelfDamage = 0,
}

truelch_BouncerFMW_AB = truelch_BouncerFMW:new{
	aFM_ModeList = { "truelch_BouncerMode1", "truelch_BouncerMode2" }, --Replaces Sweep = true
	SelfDamage = 0,
}

function truelch_BouncerFMW:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[i]
		ret:push_back(curr)
	end	
	return ret
end

function truelch_BouncerFMW:PushAttack(ret, customP2, dir)
	local spaceDamage = SpaceDamage(customP2, self.Damage, dir)
	spaceDamage.sAnimation = "SwipeClaw2"
	spaceDamage.sSound = self.SoundBase.."/attack"
	ret:AddDamage(spaceDamage)
end

function truelch_BouncerFMW:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	local currentMode = _G[self:FM_GetMode(p1)] --local currentMode = self:FM_GetMode(p1)
	local sweep = currentMode.Sweep --this is the only thing I need actually lol

	local direction = GetDirection(p2 - p1)

	if not IsEdge(p1, p2) then
		local damage = SpaceDamage(p2, 0)
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
	end

	--"ELSE" (pawn at p2 can be stable) - or we are at and edge
	self:PushAttack(ret, p2, direction) --A
	if sweep then
		--Offsets
		local offset1 = DIR_VECTORS[(direction-1)%4] --B
		local offset2 = DIR_VECTORS[(direction+1)%4] --C

		--Adjacent to p2 (sweep)
		local customP2B = p2 + offset1 --B
		local customP2C = p2 + offset2 --C

		--Push attack
		self:PushAttack(ret, customP2B, direction) --B
		self:PushAttack(ret, customP2C, direction) --C
	end

	--Move backwards
	local dirback = GetDirection(p1 - p2)
	local moveBack = SpaceDamage(p1, 0, dirback)
	moveBack.sAnimation = "airpush_"..dirback
	ret:AddDamage(moveBack)

	return ret
end

function truelch_BouncerFMW:IsTwoClickException(p1, p2)
	return IsEdge(p1, p2) or (Board:IsPawnSpace(p2) and Board:GetPawn(p2):IsGuarding())
end

function truelch_BouncerFMW:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)
	
	if Board:IsPawnSpace(p2) and Board:GetPawn(p2):IsGuarding() then
		return ret
	end
	
	for i = 1, self.Range do
		local curr = p2 + DIR_VECTORS[direction] * i
		ret:push_back(curr)
	end

	ret:push_back(p1)
	
	return ret
end

local function ComputeDamage(ret, customP2, customP3, damage)	
	local pawn2 = Board:GetPawn(customP2)
	local pawn3 = Board:GetPawn(customP3)

	local dmg2 = damage
	if pawn3 ~= nil then
		dmg2 = pawn3:GetHealth()
		if pawn3:IsArmor() then
			dmg2 = dmg2 + 1
		end
	end

	local dmg3 = damage
	if pawn2 ~= nil then
		dmg3 = pawn2:GetHealth()
		if pawn2:IsArmor() then
			dmg3 = dmg3 + 1
		end
	end

	if pawn2 ~= nil and pawn3 ~= nil then
		--Other verification here (with return)
		if pawn2:IsCorpse() and pawn3:IsCorpse() then --Maybe unnecessary
			return nil
		end

		--We only check for p2 ofc
		--Wait, it's not supposed to make attack against stable pawns impossible! 
		if pawn2:IsGuarding() then
			return nil
		end

		selfDmgCond = true --THIS! DON'T FORGET ABOUT THIS!

		if HasSquadNetworkShield() and (pawn2:IsMech() or pawn3:IsMech()) then
			if pawn2:IsMech() and pawn3:IsMech() then --really... I guess we should still do this...
				return nil
			elseif pawn2:IsMech() then
				return dmg2
			elseif pawn3:IsMech() then
				return dmg3
			end
		elseif ((pawn2:IsCorpse() or IsKindaCorpse(pawn2)) and dmg3 < dmg2) then --the case where they are BOTH corpses is already treated above
			return dmg2
		elseif ((pawn3:IsCorpse() or IsKindaCorpse(pawn3)) and dmg2 < dmg3) then
			return dmg3
		elseif (pawn2:IsShield() or pawn2:IsFrozen()) and (pawn3:IsShield() or pawn3:IsFrozen()) then
			--That can happen even with the compute before, because it happens simultaneously
			ret:AddScript("Board:GetPawn("..customP2:GetString().."):SetShield(false)")
			ret:AddScript("Board:GetPawn("..customP2:GetString().."):SetFrozen(false)")
			ret:AddScript("Board:GetPawn("..customP3:GetString().."):SetShield(false)")
			ret:AddScript("Board:GetPawn("..customP3:GetString().."):SetFrozen(false)")
			return math.min(dmg2, dmg3)
		elseif pawn2:IsShield() or pawn2:IsFrozen() then
			ret:AddScript("Board:GetPawn("..customP2:GetString().."):SetShield(false)")
			ret:AddScript("Board:GetPawn("..customP2:GetString().."):SetFrozen(false)")
			return dmg3
		elseif pawn3:IsShield() or pawn3:IsFrozen() then
			ret:AddScript("Board:GetPawn("..customP3:GetString().."):SetShield(false)")
			ret:AddScript("Board:GetPawn("..customP3:GetString().."):SetFrozen(false)")
			return dmg2
		else
			return math.min(dmg2, dmg3)
		end
	--BIG "ELSE"
	return nil
	end
end

function truelch_BouncerFMW:ThrowAttack(ret, customP2, customP3, dir, isDelay)
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

function truelch_BouncerFMW:GetFinalEffect(p1, p2, p3)
	--Vars init
	selfDmgCond = false --THIS!
    local ret = SkillEffect()

	local currentMode = _G[self:FM_GetMode(p1)]
	local sweep = currentMode.Sweep --this is the only thing I need actually lol

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
	local dmgA = ComputeDamage(ret, p2, p3, self.Damage)

	local dmgB = nil
	if sweep then
		dmgB = ComputeDamage(ret, customP2B, customP3B, self.Damage)
	end

	local dmgC = nil
	if sweep then
		dmgC = ComputeDamage(ret, customP2C, customP3C, self.Damage)
	end

	--If I put the ice / shield stuff here, they'll take the wrong amount of dmg

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

	if sweep == false then
		if dmgA ~= nil then
			delayA = true
		end
	else
		if dmgC ~= nil then
			delayC = true
		elseif dmgB ~= nil then
			delayB = true
		elseif dmgA ~= nil then
			delayA = true
		end
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
	if sweep then
		if dmgB == nil then
			self:PushAttack(ret, customP2B, dir) --B
		end	
		if dmgC == nil then
			self:PushAttack(ret, customP2C, dir) --C
		end
	end

	--Do all throw attacks (when applicable)
	if dmgA ~= nil then
		self:ThrowAttack(ret, p2, p3, dir, delayA) --A
	end
	if sweep then
		if dmgB ~= nil then
			self:ThrowAttack(ret, customP2B, customP3B, dir, delayB) --B
		end
		if dmgC ~= nil then
			self:ThrowAttack(ret, customP2C, customP3C, dir, delayC) --C
		end
	end

	--Final damages for throw attacks (after delay)
	--New: put the delay here
	if dmgA ~= nil then
		ret:AddDamage(SpaceDamage(p3, dmgA)) --A
	end
	if sweep then
		if dmgB ~= nil then
			ret:AddDamage(SpaceDamage(customP3B, dmgB)) --B
		end
		if dmgC ~= nil then
			ret:AddDamage(SpaceDamage(customP3C, dmgC)) --C
		end
	end

	--Return
    return ret
end

return this
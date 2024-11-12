-- --- IMPORT / FMW MANDATORY STUFF --- --
local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

local fmw = require(path.."fmw/api")

modApi:appendAsset("img/modes/icon_bouncer_normal_mode.png", resources.."img/modes/icon_bouncer_normal_mode.png")
modApi:appendAsset("img/modes/icon_bouncer_sweep_mode.png", resources.."img/modes/icon_bouncer_sweep_mode.png")

-- --- VARS --- --
local tipIndex
local selfDmgCond

-- --- FUNCTIONS --- --
function truelch_BouncerFMW:HasSquadNetworkShield()
	for i = 0, 2 do
		local mech = Board:GetPawn(i)
		if mech ~= nil then --shouldn't be necessary, but we never know...
			local weapons = mech:GetPoweredWeapons()
			for j = 1, 2 do
				if weapons[j] == "Passive_PlayerTurnShield" then
					--LOG("Passive_PlayerTurnShield!!!!!!!!!!!")
					return true
				end				
			end
		end
	end
	return false
end

function truelch_BouncerFMW:IsEdge(p1, p2)
	local direction = GetDirection(p2 - p1)
	local testP = p2 + DIR_VECTORS[direction]
	return not Board:IsValid(testP)
end

local kindaCorpses =
{
	"lmn_SequoiaBoss",
	"lmn_SequoiaBoss2"
}

function truelch_BouncerFMW:IsKindaCorpse(pawn)
	local pawnType = pawn:GetType()
	for _, elem in pairs(kindaCorpses) do
		if pawnType == elem then
			return true
		end
	end
	return false
end

--[[
Need to take account of:
- Ice (Done, need to test)
	pawn:IsFrozen()
- Shield (Done, need to test)
	pawn:IsShield()
- Network Shielding (Done, seems to work)
	Passive_PlayerTurnShield
- Stable pawns (Done, seems to work)
- What about pawns that leaves a corpse??? (Done, need to test)
	pawn:IsCorpse()
  -> Disable throwing a Mech or any pawn that leaves a corpse I guess
- ACID????
]]
function truelch_BouncerFMW:ComputeDamage(ret, customP2, customP3)
	--LOG("ComputeDamage(customP2:" .. customP2:GetString() .. ", customP3: " .. customP3:GetString() .. ")")
	local pawn2 = Board:GetPawn(customP2)
	local pawn3 = Board:GetPawn(customP3)

	local dmg2 = self.Damage
	if pawn3 ~= nil then
		dmg2 = pawn3:GetHealth()
		if pawn3:IsArmor() then
			dmg2 = dmg2 + 1
		end
	end

	local dmg3 = self.Damage
	if pawn2 ~= nil then
		dmg3 = pawn2:GetHealth()
		if pawn2:IsArmor() then
			dmg3 = dmg3 + 1
		end
	end

	--LOG("(Effective health) -> dmg2: " .. tostring(dmg2) .. ", dmg3: " .. tostring(dmg3))

	if pawn2 ~= nil and pawn3 ~= nil then
		--LOG("pawn2:IsCorpse(): " .. tostring(pawn2:IsCorpse()))
		--LOG("pawn3:IsCorpse(): " .. tostring(pawn3:IsCorpse()))
		--Other verification here (with return)
		if pawn2:IsCorpse() and pawn3:IsCorpse() then --Maybe unnecessary
			--LOG(" => Both are corpse so we won't throw and do the push behaviour instead -> nil")
			return nil
		end

		--We only check for p2 ofc
		--Wait, it's not supposed to make attack against stable pawns impossible! 
		if pawn2:IsGuarding() then
			--LOG(" => pawn2 is guarding -> nil")
			return nil
		end

		selfDmgCond = true --THIS! DON'T FORGET ABOUT THIS!

		if truelch_BouncerAttack:HasSquadNetworkShield() and (pawn2:IsMech() or pawn3:IsMech()) then
			--LOG(" => Here!! (squad has network shield and at least one of the pawns is a mech)")
			if pawn2:IsMech() and pawn3:IsMech() then --really... I guess we should still do this...
				--LOG(" => Both pawns are mechs!")
				return nil
			elseif pawn2:IsMech() then
				--LOG(" => pawn2 is the only mech")
				return dmg2
			elseif pawn3:IsMech() then
				--LOG(" => pawn3 is the only mech")
				return dmg3
			else
				--LOG(" => Uhh wtf??") --Should NOT happen. Right?
			end
		elseif ((pawn2:IsCorpse() or self:IsKindaCorpse(pawn2)) and dmg3 < dmg2) then --the case where they are BOTH corpses is already treated above
			--LOG(" => only pawn2 is corpse -> dmg2: " .. tostring(dmg2))
			return dmg2
		elseif ((pawn3:IsCorpse() or self:IsKindaCorpse(pawn3)) and dmg2 < dmg3) then
			--LOG(" => only pawn3 is corpse -> dmg3: " .. tostring(dmg3))
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
			--LOG(" => pawn2 is shield / frozen -> dmg3: " .. tostring(dmg3))
			return dmg3
		elseif pawn3:IsShield() or pawn3:IsFrozen() then
			ret:AddScript("Board:GetPawn("..customP3:GetString().."):SetShield(false)")
			ret:AddScript("Board:GetPawn("..customP3:GetString().."):SetFrozen(false)")
			--LOG(" => pawn3 is shield / frozen -> dmg2: " .. tostring(dmg2))
			return dmg2
		else
			--LOG(" => Regular -> math.min(dmg2, dmg3): " .. tostring(math.min(dmg2, dmg3)))
			return math.min(dmg2, dmg3)
		end
	else
		--LOG(" => nil")
		return nil
	end
end

--truelch_BouncerFMW:IsTwoClickException(p1, p2) was here, but it's below

function truelch_BouncerFMW:PushAttack(ret, customP2, dir)
	local spaceDamage = SpaceDamage(customP2, self.Damage, dir)
	spaceDamage.sAnimation = "SwipeClaw2"
	spaceDamage.sSound = self.SoundBase.."/attack"
	ret:AddDamage(spaceDamage)
end

function truelch_BouncerAttack:ThrowAttack(ret, customP2, customP3, dir, isDelay)
	--LOG("TRUELCH ThrowAttack(customP2: " .. customP2:GetString() .. ", customP3: " .. customP2:GetString() .. ")")
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


-- --- NORMAL MODE --- --
--Single target push / throw
truelch_BouncerMode1 = {
	aFM_name = "Normal Mode",
	aFM_desc = "High-explosive shell that explodes upon impact.",
	aFM_icon = "img/modes/icon_standard_shell.png",
}

CreateClass(truelch_BouncerMode1)

function truelch_BouncerMode1:targeting(point)
	local points = {}
	for i = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[i]
		points[#points+1] = curr
	end
	return points
end

function truelch_BouncerMode1:fire(p1, p2, ret)

end

-- --- SWEEP MODE --- --
-- AoE target push / throw
truelch_BouncerMode2 = atlas_ShellStd:new{
	aFM_name = "Napalm Shell",
	aFM_desc = "Explosive shell that sets an area on fire.",
	aFM_icon = "img/shells/icon_napalm_shell.png",
}

function truelch_BouncerMode2:second_targeting(p1, p2)

    --return Ranged_TC_BounceShot.GetSecondTargetArea(Ranged_TC_BounceShot, p1, p2)
end

function truelch_BouncerMode2:second_fire(p1, p2, p3)
    --return Ranged_TC_BounceShot.GetFinalEffect(Ranged_TC_BounceShot, p1, p2, p3)
end

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
}

Weapon_Texts.truelch_BouncerFMW_Upgrade1 = "Sweeping horns"
Weapon_Texts.truelch_BouncerFMW_Upgrade2 = "Reinforced carapace"

truelch_BouncerFMW_A = truelch_BouncerFMW:new{
	UpgradeDescription = "Can target any adjacent target.", --Maybe improve this description
	aFM_ModeList = { "truelch_BouncerMode1", "truelch_BouncerMode2" } --Replaces Sweep = true
}

truelch_BouncerFMW_B = truelch_BouncerFMW:new{
	UpgradeDescription = "The Mech doesn't take self-damage anymore.",
	SelfDamage = 0,
}

truelch_BouncerFMW_AB = truelch_BouncerFMW:new{
	aFM_ModeList = { "truelch_BouncerMode1", "truelch_BouncerMode2" } --Replaces Sweep = true
	SelfDamage = 0,
}

function truelch_BouncerFMW:GetTargetArea(point)
	local pl = PointList()
	local currentMode = _G[self:FM_GetMode(point)]
    
	if self:FM_CurrentModeReady(point) then 
		local points = currentMode:targeting(point)
		
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end
	 
	return pl
end

function truelch_BouncerFMW:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentMode]:fire(p1, p2, se)
		--se:AddSound(_G[currentMode].impactsound) --play sound in the fire logic
	end

	return se
end

function truelch_BouncerFMW:IsTwoClickException(p1,p2)
	--return not _G[self:FM_GetMode(p1)].aFM_twoClick
	return self:IsEdge(p1, p2) or (Board:IsPawnSpace(p2) and Board:GetPawn(p2):IsGuarding()) --test
end

function truelch_BouncerFMW:GetSecondTargetArea(p1, p2)
	local currentMode = _G[self:FM_GetMode(p1)]
    local pl = PointList()
    
	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then 
		pl = currentMode:second_targeting(p1, p2)
	end
    
    return pl 
end

function truelch_BouncerFMW:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentMode = _G[self:FM_GetMode(p1)]

	if self:FM_CurrentModeReady(p1) and currentMode.aFM_twoClick then 
		se = currentMode:second_fire(p1, p2, p3)  
	end
    
    return se
end

return this 
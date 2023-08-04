--[[
Has an issue when I use the weapon with the shortcut (1)

No matching overload found, candidates:
void __add(lua_State*,Point&,Point)

The issue is in GetSecondTargetArea()

TODO: path's size max = move?
Or we calculate the path size like this:
max = remainingMove + 2
]]

--------------------------------------------------- IMPORTS
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local customAnim = require(scriptPath.."/libs/customAnim")
local weaponArmed = require(scriptPath.."/libs/weaponArmed")


--------------------------------------------------- ANIMS
local a = ANIMS

--ANIMS.LAYER_BACK
--ANIMS.LAYER_FRONT
--ANIMS.LAYER_LESS_BACK
--ANIMS.LAYER_FLOOR

--34x23
a.truelch_hold_front = Animation:new {
	Image = "effects/hold_front.png",
	--Image = "combat/icons/movearrow_u.png", --just to test
	NumFrames = 1,
	Time = 0.19,
	PosX = -17,
	PosY = 12,
	Loop = true,
	Layer = ANIMS.LAYER_FRONT,
}

--34x23
a.truelch_hold_back = Animation:new {
	Image = "effects/hold_back.png",
	NumFrames = 1,
	Time = 0.19,
	PosX = -17,
	PosY = 12,
	Loop = true,
	Layer = ANIMS.LAYER_BACK,
}

--Maybe I'll add some fade in / out, but that sounds like a pain in the butt
--[[
local function addHold(point)
end

local function removeHold(point)
end
]]


--------------------------------------------------- VARS
local targets = {}
local previousPoint
local previousOffset
local pathOffsets = {}


--------------------------------------------------- MISC UTILITY
local function isPointAlreadyInTheList(list, p)
    for _, point in pairs(list) do
        if point == p then
        	return true
        end
    end
    return false
end

local function clear()
	--LOG("\nclear()\n")
	--Clear anims
    --Fuck it, i'll just clear the whole board
    for j = 0, 7 do
    	for i = 0, 7 do
    		local curr = Point(i, j)
			customAnim:rem(curr, "truelch_hold_back")
			customAnim:rem(curr, "truelch_hold_front")
    	end
    end

	--Clear offsets and targets
	pathOffsets = {}
	targets = {}

	--Other clear
	previousPoint = nil
	previousOffset = nil
end


--------------------------------------------------- Phase 1: add / remove targets
--Phase 1: add / remove targets
local function debugTargets()
	local str = "debugTargets() - Path Offsets list (count: " .. tostring(#targets) .. "):"
    for _,v in pairs(pathOffsets) do
        str = str .. "\n" .. v:GetString()
    end
    LOG(str)
end

-- -1 is like returning false, otherwise, return the index (to remove)
local function containTarget(pawn)
    for index, target in pairs(targets) do
    	if pawn:GetId() == target:GetId() then
        	return index --"true"
        end
    end
    return -1 --"false"
end

local function computeTarget(p1, p2, max)
	--We want to have p1 in the target area so we can just click
	--without accidentally add / remove a target to validate the first phase
	if p1 == p2 then
		return
	end

	local pawn = Board:GetPawn(p2)
	if pawn ~= nil then
		local index = containTarget(pawn) -- -1 => "false" / else => true
		if index == -1 then
	    	--Is count ok?
		    LOG("targets count: " .. tostring(#targets))
		    if #targets < max then
				--does not contain -> we add it
				table.insert(targets, pawn)
				customAnim:add(p2, "truelch_hold_back")
				customAnim:add(p2, "truelch_hold_front")
				--LOG("add at: " .. point:GetString())
		    else
		    	LOG("Count not okay!")
		    end
		else
			--contains -> we remove it
			table.remove(targets, index)
			customAnim:rem(p2, "truelch_hold_back")
			customAnim:rem(p2, "truelch_hold_front")
			--LOG("rem at: " .. point:GetString())
		end
	end
end

--[[
local function onWeaponArmed(weapon, pawnId)
	LOGF("Pawn id %s armed weapon %s", tostring(pawnId), tostring(weapon.__Id))
end

weaponArmed.events.onWeaponArmed:subscribe(onWeaponArmed)
]]

local function onWeaponUnarmed(weapon, pawnId)
	--LOGF("Pawn id %s unarmed weapon %s", tostring(pawnId), tostring(weapon.__Id))

	if targets == nil then
		--LOG("return")
		return
	end

	--new
	clear()
end

weaponArmed.events.onWeaponUnarmed:subscribe(onWeaponUnarmed)



--------------------------------------------------- Phase 2: move targets
--0         1         2
--1234567890123456789012
--truelch_ScorpionAttack
local function isScorpionWeapon(weapon)
	local sub = string.sub(weapon, 1, 22)
	--LOG("sub: " .. sub)
    return sub == "truelch_ScorpionAttack"
end

local HOOK_finalEffectEnd = function(mission, pawn, weaponId, p1, p2, p3)
	--LOG(string.format("%s has finished using %s at %s and %s!", pawn:GetMechName(), weaponId, p2:GetString(), p3:GetString()))
	if isScorpionWeapon(weaponId) then
		clear()
	end
end

local function EVENT_onModsLoaded()
	--LOG("EVENT_onModsLoaded()")
	modapiext:addFinalEffectEndHook(HOOK_finalEffectEnd)

	--test
	modApi:addTestMechEnteredHook(function(mission)
		--LOG("Player has entered the test mech scenario!")
		clear()
	end)

	--also clear at mission start?
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)


local function debugPathOffsets()
	local str = "debugPathOffsets() - pathOffsets (count: " .. tostring(#pathOffsets) .. "):"
    for _,v in pairs(pathOffsets) do
        str = str .. "\n" .. v:GetString()
    end
    LOG(str)
end

local function isPointAlreadyInTheList(p)
    for _, offset in pairs(pathOffsets) do
        if offset == p then
        	return true
        end
    end
    return false
end

--TODO: getLastPathPoint doesn't exist
local function isAdjacentTile(p1, p2)
    return p1:Manhattan(p2) == 1
end

--Start pos mean the start of each pos of pawns affected by the weapons - including the player himself
--Is the offset working from the start pos?
--*We need to ignore the position of other affected units
local function isOffsetFromStartPosOk(playerPos, point, offset)
	local offsettedPos = point + offset

	--*
	local isStartPos = false
    for _, target in pairs(targets) do
    	if target:GetSpace() == offsettedPos then
    		isStartPos = true
    	end
    end

    --Need also to consider player's pos!
    if playerPos == offsettedPos then
    	isStartPos = true
    end

	return not Board:IsBlocked(offsettedPos, PATH_PROJECTILE) or isStartPos
end

local function trim(offsetGoal)
	--Step1: create a clone list
	local clone = {}
    for _, offset in pairs(pathOffsets) do
    	table.insert(clone, offset)
    end

	--Step2: clean path
	pathOffsets = {}

	--Step3: add offsets to pathOffsets until we find offsetGoal (included)
    for _, offset in pairs(clone) do
    	table.insert(pathOffsets, offset)
    	if offset == offsetGoal then
    		break
    	end
    end
end

--TODO: trim if we find an offset we already had
local function tryAddOffset(p1, p3, max)
	local offset = p3 - p1
	local isOk = true

	--Check if not already in the list! (new)
	isOk = isOk and not isPointAlreadyInTheList(pathOffsets, offset)

    --Okay for targeted?
    for _, target in pairs(targets) do
        isOk = isOk and isOffsetFromStartPosOk(p1, target:GetSpace(), offset)
    end

    --Also need to be ok for player
    isOk = isOk and isOffsetFromStartPosOk(p1, p1, offset)

    --Max distance?
    if #pathOffsets >= max then
    	--LOG("\n\nCan't add point, the path reached its maximum size!")
    	isOk = false
    end

	--If ok -> let's go
	if isOk then
		table.insert(pathOffsets, offset)

		--Test
		previousPoint = p3
		previousOffset = offset
	end

	--Trim
	trim(offset)
end



--------------------------------------------------- WEAPON

truelch_ScorpionAttack = Skill:new{
	--Infos
	Name = "Entangling Spinneret",
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it.",
	Class = "TechnoVek",
	Icon = "weapons/truelch_scorpion_attack.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 2, 2 },

	--TC
	TwoClick = true,

	--Gameplay
	Range = 1, --radius
	Damage = 1, --will be increased in an upgrade

	--Art
	--LaunchSound = "/enemy/burnbug_2/attack_launch",

	--Test
	--if we want to not use the weapon if we don't target at least *1* enemy (or even any unit?)
	MinTargets = 0, --1
	--Upgrade people, upgrade!
	MaxTargets = 1, --1
	MaxDistance = 4, --max size of the offsets list basically

	--Tip image
	CustomTipImage = "truelch_ScorpionAttack_Tip",
	--[[
	TipImgPathOffsets = {
		Point(0, 1),
		Point(1, 0),
		Point(0, 1),
	}
	TipImage = {
		Unit = Point(2,3),
		--Target = Point(2,2),
		--Enemy = Point(2,2),
		--Second_Click = Point(3,1),
		CustomPawn = "truelch_ScorpionMech"
	},
	]]
}

Weapon_Texts.truelch_ScorpionAttack_Upgrade1 = "Extended spinneret"
Weapon_Texts.truelch_ScorpionAttack_Upgrade2 = "+1 Damage"

truelch_ScorpionAttack_A = truelch_ScorpionAttack:new{
	UpgradeDescription = "Can target any adjacent target.",
	MaxTargets = 4,
	CustomTipImage = "truelch_ScorpionAttack_Tip_A",
}

truelch_ScorpionAttack_B = truelch_ScorpionAttack:new{
	UpgradeDescription = "Increases damage by 1.",
	Damage = 2,
	CustomTipImage = "truelch_ScorpionAttack_Tip_B",
}

truelch_ScorpionAttack_AB = truelch_ScorpionAttack:new{
	MaxTargets = 4,
	Damage = 2,
	CustomTipImage = "truelch_ScorpionAttack_Tip_AB",
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
	
	--Do we want to be able to move boulders?
	--No:
	--[[
	if (pawn:GetMoveSpeed() ~= 0 or pawn:IsGrappled()) and
		pawn:GetBaseMove() ~= 0 then
		LOG("return true (2)")
		return true
	end

	LOG("return false (end)")
	return false
	]]

	--Yes:
	return true
end

function truelch_ScorpionAttack:GetTargetArea(point)
	local ret = PointList()

	ret:push_back(point) --test

	for dir = DIR_START, DIR_END do
		for range = 1, self.Range do
			local curr = point + DIR_VECTORS[dir] * range
			if self:IsControllable(curr) then
				ret:push_back(curr)
			end
		end
	end

	return ret
end

function truelch_ScorpionAttack:GetSkillEffect(p1, p2)
	--Init vars
	local ret = SkillEffect()

	--Compute target
	computeTarget(p1, p2, self.MaxTargets)

	--Iterate (target is a pawn btw)
    for _, target in pairs(targets) do
    	local targetPos = target:GetSpace()
    	local damage = SpaceDamage(targetPos, 0)
    	ret:AddDamage(damage)
    end

    --I can reset that here in preparation for phase 2 (test!)
    previousPoint = p1
    previousOffset = Point(0, 0)

    --Return
	return ret
end

-- TWO CLICKS
function truelch_ScorpionAttack:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	
	--Compute
	tmpList = {}
	if previousPoint ~= nil then
		for dir = DIR_START, DIR_END do
			local curr = previousPoint + DIR_VECTORS[dir]
			if not isPointAlreadyInTheList() then
				table.insert(tmpList, curr)
			end
		end
	end

	--Convert to point list
	for _, point in pairs(tmpList) do
		ret:push_back(point)
	end
	
	--Return
	return ret
end

--Teleport for each step (attempt fix 5: do like the diagonal move in KnightMiner's chess pawns)
--Not working (yet)
--[[
-- add sound effect
local pawnType = Pawn:GetType()
ret:AddSound(_G[pawnType].SoundLocation .. "move")
ret:AddDelay(0.1)
]]
function truelch_ScorpionAttack:GetFinalEffectTest(p1, p2, p3)
	local ret = SkillEffect()
	local direction = GetDirection(p3 - p2)

	--Not sure where to put that
	tryAddOffset(p1, p3, self.MaxDistance)
	
	--Damage first
    for i, target in pairs(targets) do
    	local spaceDamage = SpaceDamage(target:GetSpace(), self.Damage)
	    ret:AddDamage(spaceDamage)
    end

    for j, offset in pairs(pathOffsets) do
        --Player
        local curr = p1 + offset
        ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)", p1:GetString(), curr:GetString()))

        --Enemies
        for i, target in pairs(targets) do
        	local curr = target:GetSpace() + offset
        	ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)", target:GetSpace():GetString(), curr:GetString()))
        end

        --Delay
        ret:AddDelay(1)
    end

    --Ret
	return ret
end

--[[
Issue: when using NO_DELAY
If I use FULL_DELAY, it works, but all the move are done one after the other.

Fix attemps:
1: teleport all pawns to their last position
2: leap: works, but isn't thematically satisfying
3: use flying path: shouldn't work anyway since we give a list of points in the end.
	Plus, it wouldn't match the path the player created all the time. (shortest path vs custom path)
4: charge
]]
function truelch_ScorpionAttack:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local direction = GetDirection(p3 - p2)

	--Not sure where to put that
	tryAddOffset(p1, p3, self.MaxDistance)
	
	--Damage first
    for i, target in pairs(targets) do
    	local spaceDamage = SpaceDamage(target:GetSpace(), self.Damage)
	    ret:AddDamage(spaceDamage)
    end

	--Apply move to enemies
    for i, target in pairs(targets) do
    	local move = PointList()
    	move:push_back(target:GetSpace())
	    for j, offset in pairs(pathOffsets) do
	        local curr = target:GetSpace() + offset
	        move:push_back(curr)
	    end
	    --ret:AddMove(move, FULL_DELAY)
	    --ret:AddMove(move, NO_DELAY)
	    ret:AddLeap(move, NO_DELAY) --Attempt fix 2 (Pilot_Arrogant)
	    --ret:AddMove() --Attempt fix 3 (Pilot_Arrogant): use flying path
	    --ret:AddCharge(move, NO_DELAY) --Attempt fix 4
	   	--ret:AddTeleport(move, NO_DELAY) --(incorrect)
	    --ret:AddTeleport(target:GetSpace(), target:GetSpace() + pathOffsets[#pathOffsets], NO_DELAY) --Attempt fix 5
    end

    --Apply move to self
	local move = PointList()
	move:push_back(Board:GetPawn(p1):GetSpace())
    for j, offset in pairs(pathOffsets) do
        local curr = p1 + offset
        move:push_back(curr)
    end
    --ret:AddMove(move, FULL_DELAY)
    --ret:AddMove(move, NO_DELAY)
    ret:AddLeap(move, NO_DELAY) --Attempt fix 2 (Pilot_Arrogant)
    --ret:AddMove() --Attempt fix 3 (Pilot_Arrogant): use flying path
    --ret:AddCharge(move, NO_DELAY) --Attempt fix 4
    --ret:AddTeleport(move, NO_DELAY) --(incorrect)
    --ret:AddTeleport(p1, p3, NO_DELAY) --Attempt fix 5

    --Attempt fix 1: teleport all pawns to their last position
    --ret:AddDelay(0.1)

    --Enemies
    --[[
    for i, target in pairs(targets) do
    	LOG("target pos: " .. target:GetSpace():GetString())
    	ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)", target:GetSpace():GetString(), pathOffsets[#pathOffsets]:GetString()))
    end
    ]]

    --Player also? I don't think so

    --Ret
	return ret
end

--------------------------------------------------- CUSTOM TIP IMAGE
truelch_ScorpionAttack_Tip = truelch_ScorpionAttack:new{
	TwoClick = false,
	TipImgPathOffsets = {
		Point(0, -1),
		Point(1, -1), --Point(1, 0),
	},
	TipImgTgtPos = {
		Point(2, 2),
	},
	TipImage = {
		Unit = Point(2, 3),
		Target = Point(2, 2),
		Enemy = Point(2, 2),
		CustomPawn = "truelch_ScorpionMech"
	},
}

truelch_ScorpionAttack_Tip_A = truelch_ScorpionAttack_Tip:new{
	MaxTargets = 4,
	TipImgTgtPos = {
		Point(2, 2),
		Point(1, 3),
		Point(3, 3),
	},
	TipImage = {
		Unit = Point(2, 3),
		Target = Point(2, 2),
		Enemy  = Point(2, 2),
		Enemy2 = Point(1, 3),
		Enemy3 = Point(3, 3),
		CustomPawn = "truelch_ScorpionMech"
	},
}

truelch_ScorpionAttack_Tip_B = truelch_ScorpionAttack_Tip:new{
	Damage = 2,
}

truelch_ScorpionAttack_Tip_AB = truelch_ScorpionAttack_Tip:new{
	MaxTargets = 4,
	Damage = 2,
	TipImgTgtPos = {
		Point(2, 2),
		Point(1, 3),
		Point(3, 3),
	},
	TipImage = {
		Unit = Point(2, 3),
		Target = Point(2, 2),
		Enemy  = Point(2, 2),
		Enemy2 = Point(1, 3),
		Enemy3 = Point(3, 3),
		CustomPawn = "truelch_ScorpionMech"
	},
}

function truelch_ScorpionAttack_Tip:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	--CUSTOM TIP IMAGE: TARGETS
	local customTargets = {}
	--table.insert(customTargets, Board:GetPawn(Point(2, 2))) --position of the tip image enemy (TODO: change that for the upgraded version)
	for i, tgtPos in pairs(self.TipImgTgtPos) do
		table.insert(customTargets, Board:GetPawn(tgtPos))
	end
	
	--Damage first
    for i, target in pairs(customTargets) do
    	local spaceDamage = SpaceDamage(target:GetSpace(), self.Damage)
	    ret:AddDamage(spaceDamage)
    end

	--Apply move to enemies
    for i, target in pairs(customTargets) do
    	local move = PointList()
    	move:push_back(target:GetSpace())
	    for j, offset in pairs(self.TipImgPathOffsets) do
	        local curr = target:GetSpace() + offset
	        move:push_back(curr)
	    end
	    ret:AddLeap(move, NO_DELAY)
    end

    --Apply move to self
	local move = PointList()
	move:push_back(Board:GetPawn(p1):GetSpace())
    for j, offset in pairs(self.TipImgPathOffsets) do
        local curr = p1 + offset
        move:push_back(curr)
    end
    ret:AddLeap(move, NO_DELAY)

	return ret
end
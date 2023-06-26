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

--------------------------------------------------- GENERIC UTILITY
local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_Cyborg_Squad == nil then
        mission.truelch_Cyborg_Squad = {}
    end

    return mission.truelch_Cyborg_Squad
end

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
	LOG("\nclear()\n")
	--Clear anims
	--is it the original pos?
	--[[
    for index, target in pairs(targets) do
    	local curr = 
    end
    ]]

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
local targets = {}

-- -1 is like returning false, otherwise, return the index (to remove)
local function containTarget(pawn)
    for index, target in pairs(targets) do
    	if pawn:GetId() == target:GetId() then
        	return index --"true"
        end
    end
    return -1 --"false"
end

local function computeTarget(p1, p2)
	--We want to have p1 in the target area so we can just click
	--without accidentally add / remove a target to validate the first phase
	if p1 == p2 then
		return
	end

	local pawn = Board:GetPawn(p2)
	if pawn ~= nil then
		local index = containTarget(pawn) -- -1 => "false" / else => true
		if index == -1 then
			--does not contain -> we add it
			table.insert(targets, pawn)
			customAnim:add(p2, "truelch_hold_back")
			customAnim:add(p2, "truelch_hold_front")
			--LOG("add at: " .. point:GetString())
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

	--[[
	--Clear animations
    for index, target in pairs(targets) do
    	local point = target:GetSpace()
		customAnim:rem(point, "truelch_hold_back")
		customAnim:rem(point, "truelch_hold_front")
		--LOG("clear at: "..point:GetString())
    end

	--Clear targets
	targets = {}
	]]

	--new
	clear()
end

weaponArmed.events.onWeaponUnarmed:subscribe(onWeaponUnarmed)



--------------------------------------------------- Phase 2: move targets
--0         1         2
--0123456789012345678901
--truelch_ScorpionAttack
local function isScorpionWeapon(weapon)
    return string.sub(weapon, 1, 21) == "truelch_ScorpionAttack"
end

local previousPoint
local previousOffset

local pathOffsets = {}

local HOOK_finalEffectEnd = function(mission, pawn, weaponId, p1, p2, p3)
	LOG(string.format("%s has finished using %s at %s and %s!", pawn:GetMechName(), weaponId, p2:GetString(), p3:GetString()))
	if isScorpionWeapon(weaponId) then
		clear()
	end
end

local function EVENT_onModsLoaded()
	LOG("EVENT_onModsLoaded()")
	modapiext:addFinalEffectEndHook(HOOK_finalEffectEnd)

	--test
	modApi:addTestMechEnteredHook(function(mission)
		LOG("Player has entered the test mech scenario!")
		clear()
	end)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)



local function debugPathOffsets()
	local str = "debugPointList() - Path Offsets list (count: " .. tostring(#pathOffsets) .. "):"
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
local function isOffsetFromStartPosOk(point, offset)
	local offsettedPos = point + offset

	--*
	local isStartPos = false
    for _, target in pairs(targets) do
    	if target:GetSpace() == offsettedPos then
    		LOG("\n\nHERE!!!\n\n")
    		isStartPos = true
    	end
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
local function tryAddOffset(p1, p3)
	local offset = p3 - p1
	local isOk = true

	--Check if not already in the list! (new)
	isOk = isOk and not isPointAlreadyInTheList(pathOffsets, offset)

    --Okay for targeted?
    for _, target in pairs(targets) do
        isOk = isOk and isOffsetFromStartPosOk(target:GetSpace(), offset)
    end

    --Also need to be ok for player
    isOk = isOk and isOffsetFromStartPosOk(p1, offset)

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
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it",
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
	MaxTargets = 4, --1
	MaxDistance = 4, --max size of the offsets list basically

	--Tip image
	TipImage = {
		Unit = Point(2,3),
		--Target = Point(2,2),
		--Enemy = Point(2,2),
		--Second_Click = Point(3,1),
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

function truelch_ScorpionAttack:GetTargetArea(point)
	local ret = PointList()

	ret:push_back(point) --test

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

function truelch_ScorpionAttack:GetSkillEffect(p1, p2)
	--Init vars
	local ret = SkillEffect()

	--Compute target
	computeTarget(p1, p2)

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
	for dir = DIR_START, DIR_END do
		local curr = previousPoint + DIR_VECTORS[dir]
		if not isPointAlreadyInTheList() then
			table.insert(tmpList, curr)
		end
	end

	--Convert to point list
	for _, point in pairs(tmpList) do
		ret:push_back(point)
	end
	
	--Return
	return ret
end


function truelch_ScorpionAttack:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local direction = GetDirection(p3 - p2)

	--Not sure where to put that
	tryAddOffset(p1, p3)

	--Apply move to enemies
    for i, target in pairs(targets) do
    	local move = PointList()
    	move:push_back(target:GetSpace())
	    for j, offset in pairs(pathOffsets) do
	        local curr = target:GetSpace() + offset
	        move:push_back(curr)
	    end
	    ret:AddMove(move, FULL_DELAY)
    end

    --Apply move to self
	local move = PointList()
	move:push_back(Board:GetPawn(p1):GetSpace())
    for j, offset in pairs(pathOffsets) do
        local curr = p1 + offset
        move:push_back(curr)
    end
    ret:AddMove(move, FULL_DELAY)

    --Ret
	return ret
end
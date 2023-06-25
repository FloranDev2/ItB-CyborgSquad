--------------------------------------------------- IMPORTS
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local customAnim = require(scriptPath.."/libs/customAnim")
--LOG("\n\ncustomAnim: "..tostring(customAnim))

local weaponArmed = require(scriptPath.."/libs/weaponArmed")
--LOG("\n\nweaponArmed: "..tostring(weaponArmed))



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

local function computeTarget(point) --p2
	local pawn = Board:GetPawn(point)
	if pawn ~= nil then
		local index = containTarget(pawn) -- -1 => "false" / else => true
		if index == -1 then
			--does not contain -> we add it
			table.insert(targets, pawn)
			customAnim:add(point, "truelch_hold_back")
			customAnim:add(point, "truelch_hold_front")
			--LOG("add at: " .. point:GetString())
		else
			--contains -> we remove it
			table.remove(targets, index)
			customAnim:rem(point, "truelch_hold_back")
			customAnim:rem(point, "truelch_hold_front")
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

	--Clear animations
    for index, target in pairs(targets) do
    	local point = target:GetSpace()
		customAnim:rem(point, "truelch_hold_back")
		customAnim:rem(point, "truelch_hold_front")
		--LOG("clear at: "..point:GetString())
    end

	--Clear targets
	targets = {}
end

weaponArmed.events.onWeaponUnarmed:subscribe(onWeaponUnarmed)



--------------------------------------------------- Phase 2: move targets
local pathOffsets = {}

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
local function isAdjacentTile(origin, p)
    local lastPathPoint = getLastPathPoint(origin)

    if lastPathPoint == nil or p == nil then
        LOG("lastPathPoint is nil or p is nil! (shouldn't happen)")
        return false
    end
    return lastPathPoint:Manhattan(p) == 1
end

--[[
local function isPosOk(point)
	return not Board:IsBlocked(point, PATH_PROJECTILE)
end
]]

--start pos mean the start of each pos of pawns affected by the weapons - including the player himself
local function isStartPosOk(point)
	return not Board:IsBlocked(point, PATH_PROJECTILE) and isAdjacentTile() and not isPointAlreadyInTheList(p)
end


--local function tryAddOffset(mechPos, offset)
local function tryAddOffset(p1, p3)
	LOG("tryAddOffset")

	local offset = p3 - p1

	local isOk = true
	--Okay for targeted?
	for _, target in pairs(targets) do
		local curr = target:GetSpace() + offset
		isOk = isOk and isStartPosOk(curr)
	end

	--Also need to be ok for player
	isOk = isOk and isStartPosOk(p1)

	--If ok -> let's go
	if isOk then
		table.insert(pathOffsets, offset)
	end
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
	UpgradeCost = {2,2},

	--TC
	TwoClick = true,

	--Gameplay
	Range = 1,
	Damage = 1,
	--ZoneTargeting = ZONE_DIR,
	--Art
	--LaunchSound = "/enemy/burnbug_2/attack_launch",

	--Test
	--if we want to not use the weapon if we don't target at least *1* enemy (or even any unit?)
	MinTargets = 0, --1
	--Upgrade people, upgrade!
	MaxTargets = 4, --1

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

	--ret:push_back(point) --test

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
	--init vars
	local ret = SkillEffect()

	computeTarget(p2)

	--LOG("targets size: " .. tostring(#targets))
	--iterate (target is a pawn btw)
    for _, target in pairs(targets) do
    	local targetPos = target:GetSpace()
    	local damage = SpaceDamage(targetPos, 0)
    	ret:AddDamage(damage)
    end

	return ret
end

-- TWO CLICKS
function truelch_ScorpionAttack:GetSecondTargetArea(p1, p2)
	local ret = PointList()	
	
	--[[
	for i = 0, 3 do
		local curr = p1 + DIR_VECTORS[i]
		ret:push_back(curr)
	end
	]]

	LOG("GetSecondTargetArea - A (add targets)")

	--Add targets
	local tmpList = {}
	--Reminder: targets are pawns and not points!
	for _, target in pairs(targets) do
		LOG(" -> target: " .. target:GetSpace():GetString())
		table.insert(tmpList, target:GetSpace())
		LOG("  ok, now try add adjacents:")
		--Add adjacents
		for dir = 0, 3 do
			LOG("   -> dir: " .. tostring(dir))
			local adj = target:GetSpace() + DIR_VECTORS[dir]
			LOG("   -> adj: " .. adj:GetString())
			if not isPointAlreadyInTheList(tmpList, adj) then
				table.insert(tmpList, adj)
				LOG("  ---> added!")
			end
		end
	end

	LOG("GetSecondTargetArea - B (convert to point list)")

	--Convert to point list
	for _, point in pairs(tmpList) do
		ret:push_back(point)
	end

	--Try add offset --> no, move that to (final) effect
	--tryAddOffset(p2)

	LOG("GetSecondTargetArea - C (return)")
	
	--Return
	return ret
end


function truelch_ScorpionAttack:GetFinalEffect(p1, p2, p3)
	LOG("GetFinalEffect - A")
	local ret = SkillEffect()
	local direction = GetDirection(p3 - p2)

	LOG("GetFinalEffect - B")

	--Try add offset --> hope that works
	tryAddOffset(p1, p3)

	LOG("GetFinalEffect - C")

	--Test - that works!
	--[[
	pathOffsets = {}
	table.insert(pathOffsets, Point(1, 0))
	table.insert(pathOffsets, Point(2, 0))
	]]

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

    --Test


    --Ret
	return ret
end
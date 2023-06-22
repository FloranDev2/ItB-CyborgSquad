--------------------------------------------------- GENERIC UTILITY ---------------------------------------------------

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

--------------------------------------------------- CUSTOM UTILITY ---------------------------------------------------

local path = {}

local function debugPointList()
	local str = "debugPointList() - Point list (count: " .. tostring(#path) .. "): "
    for _,v in pairs(path) do
        str = str .. "\n" .. v:GetString()
    end
    LOG(str)
end

local function getLastPathPoint(origin)
    local lastPathPoint = origin
    if #path > 0 then
        lastPathPoint = path[#path]
    end
    return lastPathPoint
end

local function isAdjacentTile(origin, p)
    local lastPathPoint = getLastPathPoint(origin)

    if lastPathPoint == nil or p == nil then
        LOG("lastPathPoint is nil or p is nil! (shouldn't happen)")
        return false
    end
    return lastPathPoint:Manhattan(p) == 1
end

local function isScorpionWeapon(weapon)--1234567890123456789012
    return string.sub(weapon, 1, 22) == "truelch_ScorpionAttack"
end

local function isPointAlreadyInTheList(p)
    for _, pathPoint in pairs(path) do
        if pathPoint == p then
        	return true
        end
    end
    return false
end

--I don't know if I can clone the list without using the same reference in lua, so I'll do that manually...
local function trimPath(p)
	--Step1: create a clone list
	local clonedpath = {}
    for _, pathPoint in pairs(path) do
    	table.insert(clonedpath, pathPoint)
    end

	--Step2: clean path
	path = {}

	--Step3: add points to path until we find p (included)
    for _, pathPoint in pairs(clonedpath) do
    	table.insert(path, pathPoint)
    	if pathPoint == p then
    		--LOG("We found p -> BREAK!")
    		break
    	end
    end
end

--Making it truelch_RotaryCannon: make p == nil for some reason
local function computeAddPoint(origin, p, maxLength)
    if p == nil then
        return
    end

    if path == nil then
        path = {}
    end

    if isPointAlreadyInTheList(p) then
        --TRIM
        trimPath(p)
    elseif isAdjacentTile(origin, p) and #path < maxLength then
        table.insert(path, p)
    end
end

--------------------------------------------------- TEST ---------------------------------------------------
--Phase 1: add / remove targets
local targets = {}

-- -1 is like returning false, otherwise, return the index (to remove)
local function containTarget(pawn)
	--LOG("containTarget")
    for index, target in pairs(targets) do
    	--[[
    	LOG("index: " .. tostring(index))
    	LOG("type(pawn): " .. type(pawn))
    	LOG("type(target): " .. type(target))
    	LOG("pawn pos: " .. pawn:GetSpace():GetString())
    	LOG("target pos: " .. target:GetSpace():GetString())
    	]]
        --if pawn == target then --causes an error
    	if pawn:GetId() == target:GetId() then
        	--LOG("-> return true")
        	--return true
        	return index
        end
    end
    --LOG("-> return false")
    --return false
    return -1
end

local function computeTarget(point) --p2
	local pawn = Board:GetPawn(point)
	if pawn ~= nil then
		local index = containTarget(pawn) -- -1 => "false" / else => true
		if index == -1 then
			--does not contain -> we add it
			--LOG("contains target -> ADD")
			table.insert(targets, pawn)

		else
			--LOG("contains target -> REMOVE (todo)")
			--contains -> we remove it
			table.remove(targets, index)
		end
		--LOG("targets size: " .. tostring(#targets))
	end
end



--------------------------------------------------- WEAPON ---------------------------------------------------

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

	--old
	--[[
	local damage = SpaceDamage(p2, 0)
	if Board:IsPawnSpace(p2) then
		damage.sImageMark = "combat/icons/icon_mind_glow.png"
	else
		damage.sImageMark = "combat/icons/icon_mind_off_glow.png"
	end
	ret:AddDamage(damage)
	]]

	--LOG("p1: "..p1:GetString()..", p2: "..p2:GetString())

	computeTarget(p2)

	LOG("targets size: " .. tostring(#targets))
	--iterate (target is a pawn btw)
    for _, target in pairs(targets) do
    	local targetPos = target:GetSpace()
    	LOG("targetPos: " .. targetPos:GetString())
    	local damage = SpaceDamage(targetPos, 0)
    	damage.sImageMark = "combat/icons/icon_mind_glow.png"
    	ret:AddDamage(damage)
    end

	--return	
	return ret
end


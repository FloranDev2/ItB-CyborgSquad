--------------------------------------------------- CUSTOM UTILITY

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



--------------------------------------------------- OLD
--[[
I was wrong, we don't want an area covering the targets.
We want something like the fighter strafe: starting from the mech and change the area from the latest point added,
excluding points we already have
]]
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
    local ret = SkillEffect()
    local direction = GetDirection(p3 - p2)


    --Not sure where to put that
    previousOffset = p3 - previousPoint
    previousPoint = p3

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


local function tryAddOffset(p1, p3)
    local offset = p3 - p1
    local isOk = true

    --Check if not already in the list! (new)
    if isPointAlreadyInTheList(pathOffsets, offset)

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

        --Test
        previousPoint = p3
        previousOffset = offset
    end
end

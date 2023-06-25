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
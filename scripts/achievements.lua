local mod = modApi:getCurrentMod()
local squad = "truelch_Cyborg_Squad"

--[[
Ideas:
- VekBall: launch Vek 4 time on a Leader in a single mission.
- Skarner / Family Gathering: 
]]

-- Add Achievements
local achievements = {
	tatu_Avatar = modApi.achievements:add{
		id = "tatu_Avatar",
		name = "Avatar",
		tooltip = "Use the Razor Radula to pull enemies to water, fire, smoke and A.C.I.D. tiles in a single game.",
		image = mod.resourcePath.."img/achievements/tatu_Avatar.png",
		objective = {true,true,true,true},
		squad = squad,
	},
	tatu_Spores = modApi.achievements:add{
		id = "tatu_Spores",
		name = "Overgrowth",
		tooltip = "Have 4 Techno-Spores on the board at the same time.",
		image = mod.resourcePath.."img/achievements/tatu_Spores.png",
		objective = 1,
		squad = squad,
	},
	tatu_Kraken = modApi.achievements:add{
		id = "tatu_Kraken",
		name = "Kraken",
		tooltip = "Hit 4 enemies in a single attack of the Titanic Tentacles.",
		image = mod.resourcePath.."img/achievements/tatu_Kraken.png",
		objective = 1,
		squad = squad,
	}
}

-- Helper Functions
local function isGame()
	return true
		and Game ~= nil
		and GAME ~= nil
end

local function isMission()
	local mission = GetCurrentMission()

	return true
		and isGame()
		and mission ~= nil
		and mission ~= Mission_Test
end

local function isMissionBoard()
	return true
		and isMission()
		and Board ~= nil
		and Board:IsTipImage() == false
end

local function tatu_hash(point) return point.x + point.y*10 end

-- Hooked
-- local function tatu_skillStart(mission,pawn,weaponId,p1,p2)
	-- if isMissionBoard() then
		-- if not achievements.tatu_Hooked:isComplete() and weaponId:find("^tatu_GastropodAttack") ~= nil then
			-- local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)
			-- local dist = p1:Manhattan(target)
			-- local dist2 = p1:Manhattan(p2)
			-- if dist >= 7 and (dist2 == 1 or weaponId:find("^tatu_GastropodAttack_A") == nil) then
				-- modApi:scheduleHook(1200, function()
					-- achievements.tatu_Hooked:addProgress(1)
				-- end)
			-- end
		-- end
	-- end
-- end
-- Board:SetFire(Point(7,3),true)

-- Avatar
local function tatu_skillStart(mission,pawn,weaponId,p1,p2)
	if isMissionBoard() then
		if not achievements.tatu_Avatar:isComplete() and weaponId:find("^tatu_GastropodAttack") ~= nil then
			local direction = GetDirection(p2 - p1)
			local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)
			
			local endTarget = p1 + DIR_VECTORS[direction]
			if weaponId:find("^tatu_GastropodAttack_A") ~= nil then
				if p2 ~= target then
					endTarget = p2
				elseif p2 ~= p1 + DIR_VECTORS[direction] then
					endTarget = p2 - DIR_VECTORS[direction]
				end
			end
			
			local dist = target:Manhattan(endTarget)
			local dist2 = target:Manhattan(p1)
			local tpawn = Board:GetPawn(target)
			
			if target ~= endTarget and tpawn and tpawn:GetTeam() == TEAM_ENEMY and not tpawn:IsGuarding() then
				local delayAch = 200*dist + 100*dist2
				local achProg = {}
				achProg[1] = Board:GetTerrain(endTarget) == TERRAIN_WATER or nil
				achProg[2] = (Board:IsFire(endTarget) or Board:IsTerrain(endTarget,TERRAIN_LAVA)) or nil
				achProg[3] = Board:IsSmoke(endTarget) or nil
				achProg[4] = Board:IsAcid(endTarget) or nil
				modApi:scheduleHook(delayAch, function()
					achievements.tatu_Avatar:addProgress(achProg)
				end)
			end
		end
	end
end

local function tatu_resetTurn(mission)
	if not achievements.tatu_Avatar:isComplete() then
		if mission.tatu_AvatarTable then
			achievements.tatu_Avatar:addProgress(mission.tatu_AvatarTable)
		end
	end
end

local function tatu_nextTurn(mission)
	mission.tatu_AvatarTable = achievements.tatu_Avatar:getProgress()
end

local function tatu_GameStart()
	if not achievements.tatu_Avatar:isComplete() then
		achievements.tatu_Avatar:addProgress({false,false,false,false})
	end
end

-- Spores
local function tatu_pawnTracked(mission,pawn)
	if isMissionBoard() and not achievements.tatu_Spores:isComplete() then
		local pawnList = extract_table(Board:GetPawns(TEAM_PLAYER))
		local count = 0
		for i = 1, #pawnList do
			local currPawn = Board:GetPawn(pawnList[i])
			if currPawn:GetType():find("^tatu_Spore") ~= nil then
				count = count + 1
			end
		end
		if count >= 4 then
			achievements.tatu_Spores:addProgress(1)
			achievements.tatu_Spores.tooltip = "Have 4 Techno-Spores on the board at the same time.\n\nTechno-Spores: "..tostring(count) 
		end
	end
end

local tatu_onWindowShown = function(text_id) -- clean crew texts
	if text_id == "Escape_Title" then
		-- Spores
		if isMissionBoard() and not achievements.tatu_Spores:isComplete() then
			local pawnList = extract_table(Board:GetPawns(TEAM_PLAYER))
			local count = 0
			for i = 1, #pawnList do
				local currPawn = Board:GetPawn(pawnList[i])
				if currPawn:GetType():find("^tatu_Spore") ~= nil then
					count = count + 1
				end
			end
			achievements.tatu_Spores.tooltip = "Have 4 Techno-Spores on the board at the same time.\n\nTechno-Spores: "..tostring(count) 
		else
			achievements.tatu_Spores.tooltip = "Have 4 Techno-Spores on the board at the same time."
		end
	end
end

-- Kraken
local function tatu_finalEffectStart(mission,pawn,weaponId,p1,p2,p3)
	if isMissionBoard() then
		if not achievements.tatu_Kraken:isComplete() and weaponId:find("^tatu_StarfishAttack") ~= nil then
			local dist = p1:Manhattan(p2)
			local dist2 = p1:Manhattan(p3)
			local pList = {}
			
			-- 1st target
			if dist < 2 then
				dir = GetDirection(p2 - p1)
				pA = p2 + DIR_VECTORS[(dir+1)%4]
				pB = p2 + DIR_VECTORS[(dir-1)%4]
				if Board:IsValid(pA) then pList[tatu_hash(pA)] = pA end
				if Board:IsValid(pB) then pList[tatu_hash(pB)] = pB end
			else
				pList[tatu_hash(p2)] = p2
			end
			
			-- 2nd target
			if p3 ~= p1 then
				if dist2 < 2 then
					dir = GetDirection(p3 - p1)
					pA = p3 + DIR_VECTORS[(dir+1)%4]
					pB = p3 + DIR_VECTORS[(dir-1)%4]
					if Board:IsValid(pA) then pList[tatu_hash(pA)] = pA end
					if Board:IsValid(pB) then pList[tatu_hash(pB)] = pB end
				else
					pList[tatu_hash(p3)] = p3
				end
			end
			
			-- add achievement
			local count = 0
			for i,p in pairs(pList) do
				if Board:GetPawn(p) and Board:GetPawn(p):GetTeam() == TEAM_ENEMY then
					count = count + 1
				end
			end
			if count >= 4 then achievements.tatu_Kraken:addProgress(1) end
		end
	end
end


-- Sub / Unsub to Events
local function tatu_SquadEntered(squadId)
	if squadId == squad then
		modapiext.events.onSkillStart:subscribe(tatu_skillStart)
		modapiext.events.onPawnTracked:subscribe(tatu_pawnTracked)
		modapiext.events.onFinalEffectStart:subscribe(tatu_finalEffectStart)
		modapiext.events.onResetTurn:subscribe(tatu_resetTurn)
		modApi.events.onNextTurn:subscribe(tatu_nextTurn)
		modApi.events.onWindowShown:subscribe(tatu_onWindowShown)
		-- Avatar tooltip
		if not achievements.tatu_Avatar:isComplete() then
			local textAvatar = "\n\nWater: $1\nFire: $2\nSmoke: $3\nA.C.I.D.: $4"
			achievements.tatu_Avatar.tooltip = "Use the Razor Radula to pull enemies to water, fire, smoke and A.C.I.D. tiles in a single game."..textAvatar
		end
	end
end

local function tatu_SquadExited(squadId)
	if squadId == squad then
		modapiext.events.onSkillStart:unsubscribe(tatu_skillStart)
		modapiext.events.onPawnTracked:unsubscribe(tatu_pawnTracked)
		modapiext.events.onFinalEffectStart:unsubscribe(tatu_finalEffectStart)
		modapiext.events.onResetTurn:unsubscribe(tatu_resetTurn)
		modApi.events.onNextTurn:unsubscribe(tatu_nextTurn)
		modApi.events.onWindowShown:unsubscribe(tatu_onWindowShown)
		-- Avatar and Spores tooltip
		achievements.tatu_Spores.tooltip = "Have 4 Techno-Spores on the board at the same time."
		achievements.tatu_Avatar.tooltip = "Use the Razor Radula to pull enemies to water, fire, smoke and A.C.I.D. tiles in a single game."
	end
end

modApi.events.onSquadEnteredGame:subscribe(tatu_SquadEntered)
modApi.events.onSquadExitedGame:subscribe(tatu_SquadExited)
modApi.events.onPostStartGame:subscribe(tatu_GameStart)
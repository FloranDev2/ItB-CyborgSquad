local mod = modApi:getCurrentMod()
local squad = "truelch_Cyborg_Squad"

-- --- CONSTANT VARIABLES --- --
local SCORPSOME_KILL_GOAL = 4
local VEK_BALL_GOAL = 4

-- -- ADD ACHIEVEMENTS --- --
local achievements = {
	truelch_Highlander = modApi.achievements:add{
		id = "truelch_Highlander",
		name = "There can be only one!", --"Highlander"
		tooltip = "Finish a game without letting a single Bouncer, Burrower or Scorpion escape\n(at least one of each must have been killed during your run)",
		image = mod.resourcePath.."img/achievements/truelch_Highlander.png",
		squad = squad,
	},
	truelch_VekBall = modApi.achievements:add{
		id = "truelch_VekBall",
		name = "Vek Ball",
		tooltip = "Throw an object "..tostring(VEK_BALL_GOAL).." times at a Leader in a mission",
		image = mod.resourcePath.."img/achievements/truelch_VekBall.png",
		squad = squad,
	},
	truelch_Scorpsome = modApi.achievements:add{
		id = "truelch_Scorpsome",
		name = "Scorpsome",
		tooltip = "Kill "..tostring(SCORPSOME_KILL_GOAL).." enemies in one Scorpion's attack",
		image = mod.resourcePath.."img/achievements/truelch_Scorpsome.png",
		squad = squad,
	}
}

-- --- SOME VARS ---
--No need to store that in mission/game/achievement data since it's resolved "instantly"
local scorpsomeKillCount = 0

-- --- HELPER FUNCTIONS ---
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

local function isSquad()
	return true
		and isGame()
		and GAME.additionalSquadData.squad == squad
end

-- --- COMPLETE ACHIEVEMENT --- --
function completeHighlander(isDebug)
	if isDebug then
		LOG("completeHighlander()")
		Board:AddAlert(Point(4, 4), "Highlander completed!")
	else
		if not achievements.truelch_Highlander:isComplete() then
			achievements.truelch_Highlander:addProgress{ complete = true }
		end
	end
end

function completeVekBall(isDebug)
	if isDebug then
		LOG("completeVekBall()")
		Board:AddAlert(Point(4, 4), "Vek Ball completed!")
	else
		if not achievements.truelch_VekBall:isComplete() then
			achievements.truelch_VekBall:addProgress{ complete = true }
		end
	end
end

--Apparently, passing a nil value is basically the same as false here (which is convenient)
function completeScorpsome(isDebug)
	if isDebug then
		LOG("completeScorpsome()")
		Board:AddAlert(Point(4, 4), "Scorpsome completed!")
	else
		if not achievements.truelch_Scorpsome:isComplete() then
			achievements.truelch_Scorpsome:addProgress{ complete = true }
		end
	end
end


-- --- DATA ---
local function gameData()
	if GAME.truelch_Cyborg_Squad == nil then
		GAME.truelch_Cyborg_Squad = {}
	end

	if GAME.truelch_Cyborg_Squad.achievementData == nil then
		GAME.truelch_Cyborg_Squad.achievementData = {}
	end

	return GAME.truelch_Cyborg_Squad.achievementData
end

local function achievementData()
	--using mission will cause an error on island menu while looking in achievements tooltips
	--local mission = GetCurrentMission()
	local game = gameData()

	if game.truelch_Cyborg_Squad == nil then
		game.truelch_Cyborg_Squad = {}
	end

	if game.truelch_Cyborg_Squad.achievementData == nil then
		game.truelch_Cyborg_Squad.achievementData = {}
	end

	--Initializing other data here
	--Set to false when a bouncer, burrower or scorpion is still alive when mission ends.
	if game.truelch_Cyborg_Squad.achievementData.highlanderOk == nil then
		game.truelch_Cyborg_Squad.achievementData.highlanderOk = true
	end

	if game.truelch_Cyborg_Squad.achievementData.bouncerOk == nil then
		game.truelch_Cyborg_Squad.achievementData.bouncerOk = false
	end

	if game.truelch_Cyborg_Squad.achievementData.burrowerOk == nil then
		game.truelch_Cyborg_Squad.achievementData.burrowerOk = false
	end

	if game.truelch_Cyborg_Squad.achievementData.scorpionOk == nil then
		game.truelch_Cyborg_Squad.achievementData.scorpionOk = false
	end

	if game.truelch_Cyborg_Squad.achievementData.lastAttPawnType == nil then
		game.truelch_Cyborg_Squad.achievementData.lastAttPawnType = "" --nil is not a good idea lol
	end

	--Should be mission data
	if game.truelch_Cyborg_Squad.achievementData.vekBallCount == nil then
		game.truelch_Cyborg_Squad.achievementData.vekBallCount = 0
	end


	--Return
	return game.truelch_Cyborg_Squad.achievementData
end

--- MISC FUNCTIONS ---
--Lazy way
local bouncers =
{
	"Bouncer1",
	"Bouncer2",
	"BouncerBoss"
}

function isBouncer(pawn)
	if pawn == nil then
		LOG("Pawn is nil!")
		return false
	end
	local pawnType = pawn:GetType()
	for _, elem in pairs(bouncers) do
		if pawnType == elem then
			return true
		end
	end
	return false
end

local burrowers =
{
	"Burrower1",
	"Burrower2",
	--"BurowerBoss" --doesn't exist, but maybe it's been done in a mod...
}

function isBurrower(pawn)
	if pawn == nil then
		LOG("Pawn is nil!")
		return false
	end
	local pawnType = pawn:GetType()
	for _, elem in pairs(burrowers) do
		if pawnType == elem then
			return true
		end
	end
	return false
end

local scorpions =
{
	"Scorpion1",
	"Scorpion2",
	"ScorpionBoss",
	"Scorpion_Acid" --!
}

function isScorpion(pawn)
	if pawn == nil then
		LOG("Pawn is nil!")
		return false
	end
	local pawnType = pawn:GetType()
	for _, elem in pairs(scorpions) do
		if pawnType == elem then
			return true
		end
	end
	return false
end

--idk if I can access this: Tier = TIER_BOSS
--Works assuming every boss has "Boss" inside its name!
--[[
function isBoss(pawn)
	return string.find(pawn:GetType(), "Boss") ~= nil
end
]]

--Tatu's approach, more reliable! (thx!!)
function isBoss(pawn)
    return _G[pawn:GetType()].Tier == TIER_BOSS
end

function isBouncerAttack(weaponId)
	return string.find(weaponId, "truelch_BouncerAttack") ~= nil
end

--- TOOLTIP ---
local getTooltip = achievements.truelch_Highlander.getTooltip
achievements.truelch_Highlander.getTooltip = function(self)
	local result = getTooltip(self)

	local status = ""

	--No need to check if we're in a mission
	if isGame() and not achievements.truelch_Highlander:isComplete() then
		status = status.."\n\nNo Bouncer, Burrower or Scorpion left alive: "..tostring(achievementData().highlanderOk)
		status = status.."\nBouncer validated: " ..tostring(achievementData().bouncerOk)
		status = status.."\nBurrower validated: "..tostring(achievementData().burrowerOk)
		status = status.."\nScorpion validated: "..tostring(achievementData().scorpionOk)
	end

	result = result .. status

	return result
end

local getTooltip = achievements.truelch_VekBall.getTooltip
achievements.truelch_VekBall.getTooltip = function(self)
	local result = getTooltip(self)

	local status = ""

	--No need to check if we're in a mission
	if isGame() and isMission() and not achievements.truelch_VekBall:isComplete() then
		status = "\nObjects thrown at boss: "..tostring(achievementData().vekBallCount.." / "..tostring(VEK_BALL_GOAL))
	end

	result = result .. status

	return result
end

--- HOOKS ---
local HOOK_onNextTurn = function(mission)
	achievementData().lastAttPawnType = ""
	--LOG("HOOK_onNextTurn -> lastAttPawnType: " .. achievementData().lastAttPawnType)
end


local HOOK_onSkillStarted = function(mission, pawn, weaponId, p1, p2)
	--add isGame()?
	local exit = false
		or isSquad() == false
		or isMission() == false

	if exit then
		return
	end

	--LOG("HOOK_onSkillStarted")

	if type(weaponId) == 'table' then
		weaponId = weaponId.__Id
	end

	if weaponId ~= "Move" and weaponId ~= nil then
		achievementData().lastAttPawnType = pawn:GetType()
		--LOG(" ---> lastAttPawnType: " .. achievementData().lastAttPawnType)
		if isScorpion(pawn) == false then
			--This is what I forgot and was absolutely needed!
			scorpsomeKillCount = 0
		end
	end
end


local HOOK_onFinalEffectStarted = function(mission, pawn, weaponId, p1, p2, p3)
	--add isGame()?
	--LOG("HOOK_onFinalEffectStarted - A")
	local exit = false
		or isSquad() == false
		or isMission() == false

	if exit then
		--LOG("HOOK_onFinalEffectStarted ->return!!")
		return
	end

	--LOG("HOOK_onFinalEffectStarted - B")

	--Also needed!
	achievementData().lastAttPawnType = pawn:GetType()

	--LOG("HOOK_onFinalEffectStarted ---> lastAttPawnType: " .. achievementData().lastAttPawnType)

	--For King's Bouncer: throw stuff at boss
	if type(weaponId) == 'table' then
		weaponId = weaponId.__Id
	end

	if isScorpion(pawn) == false then
		--Also doing this here
		scorpsomeKillCount = 0
	end

	local pawn3 = Board:GetPawn(p3)
	if pawn3 ~= nil and isBoss(pawn3) and isBouncerAttack(weaponId) then
		--Vek Ball
		achievementData().vekBallCount = achievementData().vekBallCount + 1

		--Check goal
		if achievementData().vekBallCount >= VEK_BALL_GOAL then
			completeVekBall()
		end
	end
end


local HOOK_onPawnKilled = function(mission, pawn)
	if not isSquad() or not isMission() then return end

	--LOG("HOOK_onPawnKilled -> last attacker: " .. achievementData().lastAttPawnType)

	--Scorpsome achievement
	if achievementData().lastAttPawnType == "truelch_ScorpionMech" then
		--Increment kill count (no need to store the value in mission data or game data or achievement data since it's resolved instantly)
		scorpsomeKillCount = scorpsomeKillCount + 1

		--LOG("[INCR] scorpsomeKillCount: " .. tostring(scorpsomeKillCount))

		--Reached goal?
		if scorpsomeKillCount >= SCORPSOME_KILL_GOAL then
			completeScorpsome()
		end
	else
		--Reset kill count		
		scorpsomeKillCount = 0
		--LOG("[RESET] scorpsomeKillCount: " .. tostring(scorpsomeKillCount))
	end

	--Highlander achievement
	--Maybe I can at least keep that to detect if there was a Bouncer, Burrower and Scorpion during the run?
	--Would be more efficient (and safer) than checking every turn all pawns.
	if isBouncer(pawn) then
		achievementData().bouncerOk = true
	elseif isBurrower(pawn) then
		achievementData().burrowerOk = true
	elseif isScorpion(pawn) then
		achievementData().scorpionOk = true
	end
end


local HOOK_onMissionStarted = function(mission)
	--LOG("On Mission Started -> reset vek ball count")
	if isMission() then --haven't checked if test mission would trigger that
		--Reset vek ball
		achievementData().vekBallCount = 0
	end
end


local HOOK_onMissionEnded = function(mission)
	--LOG("HOOK_onMissionEnded -> Remaining units:")
	--TODO: check isSquad!
	for j = 0, 7 do
		for i = 0, 7 do		
			local point = Point(i, j)
			if Board:IsPawnSpace(point) then
				local pawn = Board:GetPawn(point)
				--LOG(" -> pawn: " .. pawn:GetType() .. " at: " .. pawn:GetSpace():GetString())
				if isBouncer(pawn) or isBurrower(pawn) or isScorpion(pawn) then
					achievementData().highlanderOk = false
				end
			end
		end
	end
end

-- --- EVENTS --- --
modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false
		or achievementData().highlanderOk == false
		or achievementData().bouncerOk == false
		or achievementData().burrowerOk == false
		or achievementData().scorpionOk == false

	if exit then
		return
	end
	
	completeHighlander()
end)

--Inspired from my previous work:
local function EVENT_onModsLoaded()
	modApi:addMissionStartHook(HOOK_onMissionStarted)
	modApi:addMissionEndHook(HOOK_onMissionEnded)
	modApi:addNextTurnHook(HOOK_onNextTurn)
	modapiext:addSkillStartHook(HOOK_onSkillStarted)
	modapiext:addFinalEffectStartHook(HOOK_onFinalEffectStarted)
	modapiext:addPawnKilledHook(HOOK_onPawnKilled)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
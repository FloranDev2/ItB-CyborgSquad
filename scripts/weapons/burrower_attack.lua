--I'm removing crack from the weapon; I couldn't undo the crack after undoing move
--And it's not what the squad really needed anyway...

local function missionData()
	local mission = GetCurrentMission()

	if mission.truelch_TruelchCyborgs == nil then
		mission.truelch_TruelchCyborgs = {}
	end

	if mission.truelch_TruelchCyborgs.burrowerCrack == nil then
		mission.truelch_TruelchCyborgs.burrowerCrack = {} --should be named "shouldUncrack" or something
		for i = 0, 2 do
			mission.truelch_TruelchCyborgs.burrowerCrack[i] = false
		end
	end

	return mission.truelch_TruelchCyborgs
end

--Is the Burrower weapon with crack upgrade powered
local function isCrack(pawn)
	LOG("isCrack...")
	if pawn == nil then
		LOG(" ... pawn is nil!")
		return false
	end
	local isCrack = false
    local weapons = pawn:GetPoweredWeapons()

    for j = 1, 2 do
    	local weapon = weapons[j]
		if type(weapon) == 'table' then
	    	weapon = weapon.__Id
		end

		if weapon ~= nil and (weapon == "truelch_BurrowerAttack_A" or weapon == "truelch_BurrowerAttack_AB") then
			isCrack = true
		end
	end
	return isCrack
end


--[[
GetTerrain(point) results:
0: Ground (cracked or not) / Conveyor Belt / Train's road
1: Building (regardless of HP and type of Building; electric plant return 1 for example)
2. ????
3: Water (also ACID water)
4: Mountain
5: Frozen Water / Damaged Ice Water (but Damaged Ice Water doesn't return true for IsCracked)
6: Forest
7: Sand tile
8: ????
9: Chasm
]]
--Is authorized terrain for cracking?
--For example, we actually don't want to crack (frozen) water
--Authorized: Ground (0), Forest (6), Sand Tile (7), ...
--There must something somewhere that has the terrain values, but I found them manually:
--Note: I might need to add some custom terrain like the spores from Into the Wild or rocks from tosx' island
--What about road tile? (that's mostly unused??)
local authCrackTerr =
{
	0, --Ground
	6, --Forest
	7  --Sand Tile
}
local function isAuthorizedTerrain(terrainId)
	for _,v in pairs(authCrackTerr) do
		if v == terrainId then
			return true
		end
	end
	return false
end

local HOOk_onSkillStart = function(mission, pawn, weaponId, p1, p2)
	local isCrack = isCrack(pawn)

	--TODO: when turn starts, register (in missionData so that it's saved when exiting the game) all cracked tiles

	if weaponId == "Move" and isCrack then
		local crack = SpaceDamage(p1, 0)
		crack.iCrack = EFFECT_CREATE
		
		Board:AddEffect(crack)
	end
end

--undone position is origin pos
local HOOK_onPawnUndoMove = function(mission, pawn, undonePosition)
	--Test 1: doesn't work
	--local crack = SpaceDamage(pawn:GetSpace(), 0)
	--crack.iCrack = EFFECT_REMOVE
	--Board:AddEffect(crack)

	--Test 2: what's the 2nd int param? Anyway, it doesn't work either...
	--Board:SetHealth(pawn:GetSpace(), 2, 2)

	--LOG("TRUELCH --- HOOK_onPawnUndoMove -> Loop:")

	local isOk = false
	for i = 0, 2 do
		--LOG("TRUELCH --- i: " .. tostring(i))
		--LOG("TRUELCH --- burrowerCrack: " .. tostring(missionData().burrowerCrack[i]))
		--Board:GetPawn(i) == pawn doesn't work, so let's compare with the unique ids
		if Board:GetPawn(i):GetId() == pawn:GetId() and missionData().burrowerCrack[i] == true then
			--LOG("TRUELCH --- ---> isOk!")
			isOk = true
		end
	end

	--Woops, I basically forgot all the verifications, thx Pilot_Arrogant for noticing it!
	if isCrack(pawn) and isOk then
		Board:SetCracked(pawn:GetSpace(), false) --thx Lemonymous!
	end
end

local HOOK_onNextTurn = function(mission)
	--LOG("TRUELCH --- Currently it is turn of team: " .. Game:GetTeamTurn())

	if Game:GetTeamTurn() == TEAM_PLAYER then
		--LOG("TRUELCH --- here")

		--go through all Mechs
		--if they possess Burrower's Weapon with crack upgrade, check if		
		--We want to crack only if it's ground underneath (or forest or sand tile, ...), frozen water cracking is not what I wanted and will be a pain to restore
		for i = 0, 2 do
			local mech = Board:GetPawn(i)
			if isCrack(mech)
				and Board:IsCracked(mech:GetSpace()) == false
				and isAuthorizedTerrain(Board:GetTerrain(mech:GetSpace())) then
				--Need to check
				--LOG("TRUELCH --- conditions are met!")
				missionData().burrowerCrack[i] = true
				--LOG("TRUELCH --- (after)")
			else
				--LOG("TRUELCH --- conditions are NOT met!")
				missionData().burrowerCrack[i] = false
				--LOG("TRUELCH --- (after)")
			end

		end
	end
end

local function EVENT_onModsLoaded()
	modapiext:addSkillStartHook(HOOk_onSkillStart)
	modapiext:addPawnUndoMoveHook(HOOK_onPawnUndoMove)
	modApi:addNextTurnHook(HOOK_onNextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

truelch_BurrowerAttack = Skill:new{
	--Infos
	Name = "Bladed Carapace",
	Description = "Damage an adjacent target and push tiles on the left and right of the target.\nIf you target a building, push all adjacent tiles instead.",
	Class = "TechnoVek",
	Icon = "weapons/truelch_burrower_attack.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },

	--Gameplay
	Damage = 2,

	Crack = false,
	Confuse = false,

	--Art
	LaunchSound = "",
	SoundBase = "/enemy/burrower_1/",
	--Explosion = "SwipeClaw2",

	--Tip image
	TipImage = {
		Unit   = Point(2, 2),
		Enemy  = Point(2, 1),
		Enemy2 = Point(1, 1),
		Target = Point(2, 1),
		CustomPawn = "truelch_BurrowerMech",

        Second_Origin = Point(2, 2),
        Second_Target = Point(3, 2),
        Building = Point(3, 2),
        Enemy3 = Point(3, 3),
	}
}


Weapon_Texts.truelch_BurrowerAttack_Upgrade1 = "Crack"
Weapon_Texts.truelch_BurrowerAttack_Upgrade2 = "Confuse"


truelch_BurrowerAttack_A = truelch_BurrowerAttack:new{
	UpgradeDescription = "Crack starting tile when moving and tiles affected by the attack that are inoccupied.\nNote: moving from frozen water won't crack it!",
	Crack = true,
}

truelch_BurrowerAttack_B = truelch_BurrowerAttack:new{
	UpgradeDescription = "Flip the attack of the main target.",
	Confuse = true,
}

truelch_BurrowerAttack_AB = truelch_BurrowerAttack:new{
	Crack = true,
	Confuse = true,
}

function truelch_ComputeCrack(point, dmg)
	if Board:IsBlocked(point, PATH_PROJECTILE) == false then
		dmg.iCrack = EFFECT_CREATE
	end
end

function truelch_BurrowerAttack:GetTargetArea(point)
	local ret = PointList()

	--Debug shit
	--[[
	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			ret:push_back(curr)
		end
	end
	]]
	
	--Regular stuff
	for dir = DIR_START, DIR_END do
		local curr = Point(point + DIR_VECTORS[dir])
		ret:push_back(curr)
	end
	
	return ret
end

function truelch_BurrowerAttack:RegularEffect(ret, p1, p2)
	local direction = GetDirection(p2 - p1)

	--Center
	local dmg1 = SpaceDamage(p2, self.Damage)
	if self.Confuse == true then
		dmg1 = SpaceDamage(p2, self.Damage, DIR_FLIP)
	end
	dmg1.sSound = self.SoundBase.."attack"
	dmg1.sAnimation = "SwipeClaw2"

	if self.Crack == true then
		truelch_ComputeCrack(p2, dmg1)
	end
	
	ret:AddDamage(dmg1)

	--Right
	local dir2 = (direction - 1)% 4
	local dmg2 = SpaceDamage(p2 + DIR_VECTORS[dir2], 0, dir2)
	dmg2.sAnimation = "airpush_"..dir2

	if self.Crack == true then
		truelch_ComputeCrack(p2 + DIR_VECTORS[dir2], dmg2)
	end

	ret:AddDamage(dmg2)

	--Left
	local dir3 = (direction + 1)% 4
	local dmg3 = SpaceDamage(p2 + DIR_VECTORS[dir3], 0, dir3)
	dmg3.sAnimation = "airpush_"..dir3

	if self.Crack == true then
		truelch_ComputeCrack(p2 + DIR_VECTORS[dir3], dmg3)
	end

	ret:AddDamage(dmg3)
end

function truelch_BurrowerAttack:BuildingEffect(ret, p2)
	--Other effects
	local sound = SpaceDamage(p2)
	sound.sSound = self.SoundBase.."attack" --tmp
	ret:AddDamage(sound)

	ret:AddBounce(p2, 3)

	ret:AddDelay(0.2)

	for dir = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[dir]
		local push = SpaceDamage(curr, 0, dir)
		push.sAnimation = "airpush_"..dir

		if self.Crack == true then
			truelch_ComputeCrack(curr, push)
		end

		ret:AddDamage(push)
		ret:AddBounce(curr, 2)
	end

	ret:AddDelay(0.2)

	for dir2 = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[dir2] * 2
		ret:AddBounce(curr, 1)
	end
end

function truelch_BurrowerAttack:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	if Board:IsBuilding(p2) then
		self:BuildingEffect(ret, p2)
	else
		self:RegularEffect(ret, p1, p2)
	end

	return ret
end
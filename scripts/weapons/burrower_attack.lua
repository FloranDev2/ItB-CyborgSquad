local function isCrack(weapon)
	if type(weapon) == 'table' then
    	weapon = weapon.__Id
	end
	if weapon == nil then
		return false
	end
    local sub = string.sub(weapon, 9, 15)
    if sub == "FAB5000" then
    	return true
    end
	return false
end

local HOOk_onSkillStart = function(mission, pawn, weaponId, p1, p2)
--local HOOk_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
	--LOG(string.format("%s is using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))
	--LOG(string.format("%s has finished using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))

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

	--LOG("isCrack: " .. tostring(isCrack))

	if weaponId == "Move" and isCrack then
		local crack = SpaceDamage(p1, 0)
		crack.iCrack = EFFECT_CREATE
		Board:AddEffect(crack)
	end
end

local function EVENT_onModsLoaded()
	modapiext:addSkillStartHook(HOOk_onSkillStart) --same
	--modapiext:addSkillEndHook(HOOk_onSkillEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

truelch_BurrowerAttack = Skill:new{
	--Infos
	Name = "Bladed Carapace",
	Description = "Damages an adjacent target. Pushes tiles on the left and right of the target.",
	Class = "TechnoVek",
	Icon = "weapons/truelch_burrower_attack.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 1, 2 },

	--Gameplay
	--PathSize = 1, --what does that mean?
	--ZoneTargeting = ZONE_DIR, --what does that mean?
	Damage = 2,

	Crack = false,
	Confuse = false,

	--Art
	LaunchSound = "",
	SoundBase = "/enemy/burrower_1/",
	Explosion = "SwipeClaw2",

	--Tip image
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,2),
		Enemy2 = Point(1,2),
		Enemy2 = Point(3,2),
		Target = Point(2,2),
		CustomPawn = "truelch_BurrowerMech"
	}
}

Weapon_Texts.truelch_BurrowerAttack_Upgrade1 = "Crack"
Weapon_Texts.truelch_BurrowerAttack_Upgrade2 = "Confuse"

truelch_BurrowerAttack_A = truelch_BurrowerAttack:new{
	UpgradeDescription = "Crack the previous tile it was standing one before the move.",
	Crack = true,
}

truelch_BurrowerAttack_B = truelch_BurrowerAttack:new{
	UpgradeDescription = "Confuses hit enemies.",
	Confuse = true,
}

truelch_BurrowerAttack_AB = truelch_BurrowerAttack:new{
	Crack = true,
	Confuse = true,
}

function truelch_BurrowerAttack:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		local curr = Point(point + DIR_VECTORS[dir])
		ret:push_back(curr)
	end
	
	return ret
end

function truelch_BurrowerAttack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	--Center
	local dmg1 = SpaceDamage(p2, self.Damage)
	if self.Confuse == true then
		dmg1 = SpaceDamage(p2, self.Damage, DIR_FLIP)
	end
	dmg1.sSound = self.SoundBase.."attack"
	ret:AddDamage(dmg1)

	--Right
	local dir2 = (direction - 1)% 4
	local dmg2 = SpaceDamage(p2 + DIR_VECTORS[dir2], 0, dir2)
	ret:AddDamage(dmg2)

	--Left
	local dir3 = (direction + 1)% 4
	local dmg3 = SpaceDamage(p2 + DIR_VECTORS[dir3], 0, dir3)
	ret:AddDamage(dmg3)

	return ret
end
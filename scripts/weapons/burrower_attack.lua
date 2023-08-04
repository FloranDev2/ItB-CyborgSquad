local HOOk_onSkillStart = function(mission, pawn, weaponId, p1, p2)
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

	if weaponId == "Move" and isCrack then
		local crack = SpaceDamage(p1, 0)
		crack.iCrack = EFFECT_CREATE
		Board:AddEffect(crack)
	end
end

local function EVENT_onModsLoaded()
	modapiext:addSkillStartHook(HOOk_onSkillStart)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

truelch_BurrowerAttack = Skill:new{
	--Infos
	Name = "Bladed Carapace",
	Description = "Damages an adjacent target and pushes tiles on the left and right of the target.\nIf you target a building, pushes all adjacent tiles instead.",
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
		Unit   = Point(2, 3),
		Enemy  = Point(2, 2),
		Enemy2 = Point(1, 2),
		Enemy2 = Point(3, 2),
		Target = Point(2, 2),
		CustomPawn = "truelch_BurrowerMech"
	}
}

Weapon_Texts.truelch_BurrowerAttack_Upgrade1 = "Crack"
Weapon_Texts.truelch_BurrowerAttack_Upgrade2 = "Confuse"

truelch_BurrowerAttack_A = truelch_BurrowerAttack:new{
	UpgradeDescription = "Cracks the previous tile it was standing one before the move.",
	Crack = true,
}

truelch_BurrowerAttack_B = truelch_BurrowerAttack:new{
	UpgradeDescription = "Flips the attack of the main target.",
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

function truelch_BurrowerAttack:RegularEffect(ret, p1, p2)
	local direction = GetDirection(p2 - p1)

	--Center
	local dmg1 = SpaceDamage(p2, self.Damage)
	if self.Confuse == true then
		dmg1 = SpaceDamage(p2, self.Damage, DIR_FLIP)
	end
	dmg1.sSound = self.SoundBase.."attack"
	dmg1.sAnimation = "SwipeClaw2"
	ret:AddDamage(dmg1)

	--Right
	local dir2 = (direction - 1)% 4
	local dmg2 = SpaceDamage(p2 + DIR_VECTORS[dir2], 0, dir2)
	dmg2.sAnimation = "airpush_"..dir2
	ret:AddDamage(dmg2)

	--Left
	local dir3 = (direction + 1)% 4
	local dmg3 = SpaceDamage(p2 + DIR_VECTORS[dir3], 0, dir3)
	dmg3.sAnimation = "airpush_"..dir3
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
		ret:AddDamage(push)
		ret:AddBounce(curr, 2)

		--We don't want that actually
		--[[
		if self.Confuse == false then

		else

		end
		]]
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
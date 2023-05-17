-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-- add assets from our mod so the game can find them.

local iconPath = path .."img/weapons/"

local files = {
	"truelch_scorpion_attack.png",
	"truelch_bouncer_attack.png",
	"truelch_burrower_attack.png"
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/weapons/".. file, iconPath .. file)
end


truelch_ScorpionAttack = Skill:new{
	--Infos
	Name = "Entangling Spinneret",
	Description = "Target an adjacent enemy, and move it with the Mech, damaging it",
	Class = "TechnoVek",

	--Shop
	Rarity = 1,
	PowerCost = 0,
	Upgrades = 2, --2
	UpgradeCost = {}, --{2,2}

	--Gameplay
	Damage = 1,
	ZoneTargeting = ZONE_DIR,

	--Art
	Icon = "weapons/truelch_scorpion_attack.png",
	LaunchSound = "/enemy/burnbug_2/attack_launch",

	--Tip image
	TipImage = {
		Unit = Point(2,3),
	}
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

function truelch_ScorpionAttack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
		
	return ret
end


-------------------
-- Spore Spawner --
-------------------

tatu_PlasmodiaAttack = Deployable:new{
	Name = "Spore Spawner",
	Description = "Launch a Techno-Spore that shoots projectiles.",
	Deployed = "tatu_Spore",
	Icon = "weapons/tatu_plasmodia_attack.png",
	Projectile = "advanced/effects/shotup_totemB.png",
	Class = "TechnoVek",
	PowerCost = 0,
	PushAdj = false,
	Limited = 0,
	ImpactSound = "/enemy/shaman_2/attack_impact",
	LaunchSound = "/enemy/shaman_2/attack_launch",
	Upgrades = 2,
	UpgradeCost = {2,2},
	TipImage = {
		Unit = Point(3,3),
		Target = Point(3,1),
		Second_Origin = Point(3,1),
		Second_Target = Point(2,1),
		Enemy = Point(1,1),
		CustomPawn = "tatu_PlasmodiaMech",
	}
}

Weapon_Texts.tatu_PlasmodiaAttack_Upgrade1 = "+1 Spore Health"
Weapon_Texts.tatu_PlasmodiaAttack_Upgrade2 = "+1 Spore Damage"

tatu_PlasmodiaAttack_A = tatu_PlasmodiaAttack:new{
	UpgradeDescription = "Increases Techno-Spore health by 1.",
	Deployed = "tatu_Spore_B",
}

tatu_PlasmodiaAttack_B = tatu_PlasmodiaAttack:new{
	UpgradeDescription = "Increases Techno-Spore projectile damage by 1.",
	Deployed = "tatu_Spore_A",
}

tatu_PlasmodiaAttack_AB = tatu_PlasmodiaAttack:new{
	Deployed = "tatu_Spore_AB",
}

function tatu_PlasmodiaAttack:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	
	-- change spore color
	local oldOffset = tatu_Spore.ImageOffset
	ret:AddScript(string.format("_G[%q].ImageOffset = Board:GetPawn(%s):GetImageOffset()",self.Deployed,p1:GetString()))
	
	-- weapon effect
	local damage = SpaceDamage(p2)
	ret:AddArtillery(damage,self.Projectile,FULL_DELAY)
	
	damage.sPawn = self.Deployed
	ret:AddDamage(damage)
	ret:AddScript(string.format("Board:GetPawn(%s):SetTeam(Board:GetPawn(%s):GetTeam())",p2:GetString(),p1:GetString()))
	
	-- restore color for preview
	ret:AddScript(string.format("_G[%q].ImageOffset = %i",self.Deployed,oldOffset))
	ret:AddVoice("PodCollected",-1)--Board:GetPawn(p1):GetId())
	
	return ret
end


-- Spore weapon
tatu_SporeAttack = Skill:new{
	Name = "Spite Spitter",
	Class = "TechnoVek",
	Description = "Damage self to launch a projectile that damages and pushes the target.",
	Icon = "weapons/tatu_spore_attack.png",
	Class = "Enemy",
	LaunchSound = "/enemy/totem_2/attack",
	ProjectileArt = "effects/shot_fireflyB",
	HitExplosion = "ExploFireflyB",
	ZoneTargeting = ZONE_DIR,
	Damage = 1,
	SelfDamage = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Friend = Point(2,1),
		CustomPawn = "tatu_Spore",
		CustomEnemy = "Scorpion2",
	}
}

tatu_SporeAttack_A = tatu_SporeAttack:new{
	Damage = 2,
}

function tatu_SporeAttack:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
	
	ret:AddDamage(SpaceDamage(p1,self.SelfDamage))
	
	local damage = SpaceDamage(target, self.Damage, dir)
	damage.sAnimation = self.HitExplosion
	ret:AddProjectile(damage,self.ProjectileArt)
	
	return ret
end


-----------------------
-- Titanic Tentacles --
-----------------------

tatu_StarfishAttack = Skill:new{
	Name = "Titanic Tentacles",
	Description = "Strike any number of oblique tiles with powerful tentacles.",
	Class = "TechnoVek",
	Icon = "weapons/tatu_starfish_attack.png",
	LaunchSound = "/enemy/starfish_2/attack",
	Rarity = 3,
	Range = 1,
	Damage = 2, -- Upgrades
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2,3},
	TwoClick = true,
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(1,1),
		Enemy2 = Point(3,1),
		Enemy3 = Point(1,3),
		Building = Point(3,3),
		Target = Point(2,1),
		Second_Click = Point(1,3),
		CustomPawn = "tatu_StarfishMech",
	}
}

Weapon_Texts.tatu_StarfishAttack_Upgrade1 = "+1 Damage"
Weapon_Texts.tatu_StarfishAttack_Upgrade2 = "+1 Damage"

tatu_StarfishAttack_A = tatu_StarfishAttack:new{
	UpgradeDescription = "Increases damage to all tiles by 1.",
	Damage = 3,
}

tatu_StarfishAttack_B = tatu_StarfishAttack:new{
	UpgradeDescription = "Increases damage to all tiles by 1.",
	Damage = 3,
}

tatu_StarfishAttack_AB = tatu_StarfishAttack:new{
	Damage = 4,
}

function tatu_StarfishAttack:GetTargetArea(p1)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[i]
		local curr2 = curr + DIR_VECTORS[(i+1)%4]
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end
		if Board:IsValid(curr2) then
			ret:push_back(curr2)
		end
	end
	return ret
end

function tatu_StarfishAttack:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local dist = p1:Manhattan(p2)
	local p3 = p1
	
	ret:push_back(p1)
	for i = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[i]
		local curr2 = curr + DIR_VECTORS[(i+1)%4]
		if Board:IsValid(curr) then --and curr ~= p2 then
			ret:push_back(curr)
		end
		if Board:IsValid(curr2) then --and curr2 ~= p2 then
			ret:push_back(curr2)
		end
	end
	return ret
end

function tatu_StarfishAttack:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local dist = p1:Manhattan(p2)
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
	
	-- add damage
	for i,p in pairs(pList) do
		local damage = SpaceDamage(p,self.Damage)
		damage.sAnimation = "explostarfish_"..tatu_pos(p1,p)
		ret:AddDamage(damage)
	end
	
	return ret
end

function tatu_StarfishAttack:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
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
	
	-- add damage
	for i,p in pairs(pList) do
		local damage = SpaceDamage(p,self.Damage)
		damage.sAnimation = "explostarfish_"..tatu_pos(p1,p)
		ret:AddDamage(damage)
	end
	
	return ret
end

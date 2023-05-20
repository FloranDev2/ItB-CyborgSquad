-- add color palette
local pathScripts = mod_loader.mods[modApi.currentMod].scriptPath
modApi:addPalette({
		ID = "truelch_CyborgsColor",
		Name = "Truelch's Cyborgs' Color",
		PlateHighlight = {255, 198, 138},	--lights
		PlateLight     = {243, 94, 222},	--main highlight
		PlateMid       = {133, 55, 152},	--main light
		PlateDark      = {56, 34, 78},		--main mid
		PlateOutline   = {9, 22, 27},		--main dark
		PlateShadow    = {155, 63, 63},		--metal dark
		BodyColor      = {255, 95, 75},		--metal mid
		BodyHighlight  = {255, 187, 131},	--metal light
})
local palette = modApi:getPaletteImageOffset("truelch_CyborgsColor")

-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-------------------
-- Cyborg Pilots --
-------------------

local names = {
	"ScorpionMech",
	"BouncerMech",
	"BurrowerMech",
}
for _, ptname in pairs(names) do
	modApi:appendAsset("img/portraits/pilots/Pilot_truelch_"..ptname..".png",path.."img/portraits/Pilot_truelch_"..ptname..".png")
	CreatePilot{
		Id = "Pilot_truelch_"..ptname,
		Personality = "Vek",
		Sex = SEX_VEK,
		Rarity = 0,
		Skill = "Survive_Death",
		Blacklist = {"Invulnerable", "Popular"},
	}
end

--------------------
-- Scorpion Mech ---
--------------------

-- locate our mech assets.
local scorpionPath = path .."img/mech_scorpion/"

-- make a list of our files.
local files = {
	"truelch_mech_scorpion.png",
	"truelch_mech_scorpion_a.png",
	"truelch_mech_scorpion_w.png",
	"truelch_mech_scorpion_broken.png",
	"truelch_mech_scorpion_w_broken.png",
	"truelch_mech_scorpion_ns.png",
	"truelch_mech_scorpion_h.png"
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, scorpionPath .. file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.truelch_mech_scorpion =			a.MechUnit:new{Image = "units/player/tatu_mech_gastropod.png", PosX = -23, PosY = 1 }
a.truelch_mech_scorpiona =			a.MechUnit:new{Image = "units/player/tatu_mech_gastropod_a.png", PosX = -23, PosY = 1, NumFrames = 4 }
a.truelch_mech_scorpionw =			a.MechUnit:new{Image = "units/player/tatu_mech_gastropod_w.png", PosX = -21, PosY = 10 }
a.truelch_mech_scorpion_broken =	a.MechUnit:new{Image = "units/player/tatu_mech_gastropod_broken.png", PosX = -23, PosY = 1 }
a.truelch_mech_scorpionw_broken =	a.MechUnit:new{Image = "units/player/tatu_mech_gastropod_w_broken.png", PosX = -21, PosY = 10 }
a.truelch_mech_scorpion_ns =		a.MechIcon:new{Image = "units/player/tatu_mech_gastropod_ns.png"}

tatu_GastropodMech = Pawn:new {
	Name = "Techno-Gastropod",
	Class = "TechnoVek",
	Health = 3,
	MoveSpeed = 3,
	Image = "tatu_mech_gastropod",
	ImageOffset = palette,
	SkillList = { "tatu_GastropodAttack" },--{ "Prime_Punchmech" }
	SoundLocation = "/enemy/burnbug_2/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
}

--------------------
-- Starfish Mech ---
--------------------

-- locate our mech assets.
local starfishPath = path .."img/mech_starfish/"

-- make a list of our files.
local files = {
	"tatu_mech_starfish.png",
	"tatu_mech_starfish_a.png",
	"tatu_mech_starfish_w.png",
	"tatu_mech_starfish_broken.png",
	"tatu_mech_starfish_w_broken.png",
	"tatu_mech_starfish_ns.png",
	"tatu_mech_starfish_h.png"
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, starfishPath .. file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.tatu_mech_starfish =			a.MechUnit:new{Image = "units/player/tatu_mech_starfish.png", PosX = -25, PosY = -2 }
a.tatu_mech_starfisha =			a.MechUnit:new{Image = "units/player/tatu_mech_starfish_a.png", PosX = -25, PosY = -2, NumFrames = 4 }
a.tatu_mech_starfishw =			a.MechUnit:new{Image = "units/player/tatu_mech_starfish_w.png", PosX = -23, PosY = 9 }
a.tatu_mech_starfish_broken =	a.MechUnit:new{Image = "units/player/tatu_mech_starfish_broken.png", PosX = -25, PosY = -2 }
a.tatu_mech_starfishw_broken =	a.MechUnit:new{Image = "units/player/tatu_mech_starfish_w_broken.png", PosX = -23, PosY = 9 }
a.tatu_mech_starfish_ns =		a.MechIcon:new{Image = "units/player/tatu_mech_starfish_ns.png"}

tatu_StarfishMech = Pawn:new {
	Name = "Techno-Starfish",
	Class = "TechnoVek",
	Health = 2,
	MoveSpeed = 4,
	Image = "tatu_mech_starfish",
	ImageOffset = palette,
	SkillList = { "tatu_StarfishAttack" },--{ "Prime_Punchmech" }
	SoundLocation = "/enemy/starfish_2/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
}

---------------------
-- Plasmodia Mech ---
---------------------

-- locate our mech assets.
local plasmodiaPath = path .."img/mech_plasmodia/"

-- make a list of our files.
local files = {
	"tatu_mech_plasmodia.png",
	"tatu_mech_plasmodia_a.png",
	"tatu_mech_plasmodia_w.png",
	"tatu_mech_plasmodia_broken.png",
	"tatu_mech_plasmodia_w_broken.png",
	"tatu_mech_plasmodia_ns.png",
	"tatu_mech_plasmodia_h.png"
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, plasmodiaPath .. file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.tatu_mech_plasmodia =				a.MechUnit:new{Image = "units/player/tatu_mech_plasmodia.png", PosX = -26, PosY = -9 }
a.tatu_mech_plasmodiaa =			a.MechUnit:new{Image = "units/player/tatu_mech_plasmodia_a.png", PosX = -26, PosY = -9, NumFrames = 6 }
a.tatu_mech_plasmodiaw =			a.MechUnit:new{Image = "units/player/tatu_mech_plasmodia_w.png", PosX = -15, PosY = 4 }
a.tatu_mech_plasmodia_broken =		a.MechUnit:new{Image = "units/player/tatu_mech_plasmodia_broken.png", PosX = -26, PosY = -9 }
a.tatu_mech_plasmodiaw_broken =		a.MechUnit:new{Image = "units/player/tatu_mech_plasmodia_w_broken.png", PosX = -15, PosY = 4 }
a.tatu_mech_plasmodia_ns =			a.MechIcon:new{Image = "units/player/tatu_mech_plasmodia_ns.png"}

tatu_PlasmodiaMech = Pawn:new {
	Name = "Techno-Plasmodia",
	Class = "TechnoVek",
	Health = 3,
	MoveSpeed = 2,
	Image = "tatu_mech_plasmodia",
	ImageOffset = palette,
	SkillList = { "tatu_PlasmodiaAttack" },
	SoundLocation = "/enemy/shaman_2/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
}

------------
-- Spore ---
------------

-- locate our mech assets.
local sporePath = path .."img/spore/"

-- make a list of our files.
local files = {
	"tatu_spore.png",
	"tatu_spore_a.png",
	"tatu_spore_death.png",
	"tatu_spore_emerge.png",
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, sporePath .. file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.tatu_spore =		a.MechUnit:new{Image = "units/player/tatu_spore.png", PosX = -14, PosY = -2 }
a.tatu_sporea =		a.MechUnit:new{Image = "units/player/tatu_spore_a.png", PosX = -14, PosY = -3, NumFrames = 4, Time = 0.45} --, Time = 0.9 }
a.tatu_sporee =		a.BaseEmerge:new{Image = "units/player/tatu_spore_emerge.png", PosX = -15, PosY = -3, NumFrames = 8 }
a.tatu_spored =		a.EnemyUnit:new{Image = "units/player/tatu_spore_death.png", PosX = -21, PosY = -2, NumFrames = 8, Time = 0.14, Loop = false }

tatu_Spore = Pawn:new{
	Name = "Techno-Spore",
	Health = 1,
	SkillList = { "tatu_SporeAttack" },
	MoveSpeed = 0,
	Image = "tatu_spore",
	ImageOffset = palette,
	Minor = true,
	SoundLocation = "/enemy/totem_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB
}
AddPawn("tatu_Spore")

tatu_Spore_A = Pawn:new{
	Name = "Techno-Spore",
	Health = 1,
	SkillList = { "tatu_SporeAttack_A" },
	MoveSpeed = 0,
	Image = "tatu_spore",
	ImageOffset = palette,
	Minor = true,
	SoundLocation = "/enemy/totem_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB
}
AddPawn("tatu_Spore_A")

tatu_Spore_B = Pawn:new{
	Name = "Techno-Spore",
	Health = 2,
	SkillList = { "tatu_SporeAttack" },
	MoveSpeed = 0,
	Image = "tatu_spore",
	ImageOffset = palette,
	Minor = true,
	SoundLocation = "/enemy/totem_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB
}
AddPawn("tatu_Spore_B")

tatu_Spore_AB = Pawn:new{
	Name = "Techno-Spore",
	Health = 2,
	SkillList = { "tatu_SporeAttack_A" },
	MoveSpeed = 0,
	Image = "tatu_spore",
	ImageOffset = palette,
	Minor = true,
	SoundLocation = "/enemy/totem_2/",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB
}
AddPawn("tatu_Spore_AB")

-- supress spore dialogs
local oldTriggerVoiceEvent = TriggerVoiceEvent
function TriggerVoiceEvent(event, ...)
	local pawn = Board and Board:GetPawn(event.pawn1)
	if event.pawn1 >= 0 and pawn and pawn:GetType():find("^tatu_Spore") ~= nil then
		return -- suppress dialog
	end
	oldTriggerVoiceEvent(event, ...)
end

-- fix spore portraits on load
local HOOK_postLoadGameHook = function(mission)
	modApi:conditionalHook(
		function()
			return GetCurrentMission()
		end,
		function()
			local pawnList = extract_table(Board:GetPawns(TEAM_PLAYER))
			for i = 1, #pawnList do
				local currPawn = Board:GetPawn(pawnList[i])
				local currType = currPawn:GetType()
				if currType:find("^tatu_Spore") ~= nil then
					local pos = currPawn:GetSpace()
					local owner = currPawn:GetOwner()
					local offset = currPawn:GetImageOffset()
					Board:RemovePawn(currPawn)
					
					currPawn = PAWN_FACTORY:CreatePawn(currType)
					currPawn:SetTeam(TEAM_PLAYER)
					currPawn:SetImageOffset(offset)
					Board:AddPawn(currPawn)
					currPawn:SetSpace(pos)
					currPawn:SetOwner(owner)
				end
			end
		end
	)
end

local function EVENT_onModsLoaded()
	modApi:addPostLoadGameHook(HOOK_postLoadGameHook)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

local mod = modApi:getCurrentMod()

-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath
	modApi:appendAsset("img/portraits/pilots/Pilot_Meta_TechnoDigger.png", path .."img/portraits/pilots/Pilot_Meta_TechnoDigger.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_Meta_TechnoTumblebug.png", path .."img/portraits/pilots/Pilot_Meta_TechnoTumblebug.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_Meta_TechnoMoth.png", path .."img/portraits/pilots/Pilot_Meta_TechnoMoth.png")
-- locate our mech assets.
local mechPath = path .."img/units/player/"
-- make a list of our files.
local files = {
	"Meta_TechnoDigger.png",
	"Meta_TechnoDiggera.png",
	"Meta_TechnoDigger_w.png",
	"Meta_TechnoDigger_w_broken.png",
	"Meta_TechnoDigger_broken.png",
	"Meta_TechnoDigger_ns.png",
	"Meta_TechnoDigger_h.png",
	"Meta_TechnoDigger_emerge.png",
}
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, mechPath .. file)
end
local a=ANIMS
	a.Meta_TechnoDigger =a.MechUnit:new{Image="units/player/Meta_TechnoDigger.png", PosX = -22, PosY = 4}
	a.Meta_TechnoDiggera = a.MechUnit:new{Image="units/player/Meta_TechnoDiggera.png",  PosX = -20, PosY = 4, NumFrames = 4 }
	a.Meta_TechnoDiggerw = a.MechUnit:new{Image="units/player/Meta_TechnoDigger_w.png", -22, PosY = 10}
	a.Meta_TechnoDigger_broken = a.MechUnit:new{Image="units/player/Meta_TechnoDigger_broken.png", PosX = -22, PosY = 4 }
	a.Meta_TechnoDiggerw_broken = a.MechUnit:new{Image="units/player/Meta_TechnoDigger_w_broken.png", PosX = -20, PosY = 10 }
	a.Meta_TechnoDigger_ns = a.MechIcon:new{Image="units/player/Meta_TechnoDigger_ns.png"}
	a.Meta_TechnoDiggere = a.MechIcon:new{Image="units/player/Meta_TechnoDigger_emerge.png", PosX = -20, PosY = 4, Loop = false, NumFrames = 10, Time = .07}

-- make a list of our files.
local files = {
	"Meta_TechnoTumblebug.png",
	"Meta_TechnoTumblebuga.png",
	"Meta_TechnoTumblebug_w.png",
	"Meta_TechnoTumblebug_w_broken.png",
	"Meta_TechnoTumblebug_broken.png",
	"Meta_TechnoTumblebug_ns.png",
	"Meta_TechnoTumblebug_h.png",
	"Meta_TechnoTumblebug_emerge.png",
}
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, mechPath .. file)
end
local a=ANIMS
	a.Meta_TechnoTumblebug =	a.MechUnit:new{Image = "units/player/Meta_TechnoTumblebug.png", PosX = -21, PosY = -3}
	a.Meta_TechnoTumblebuga =	a.MechUnit:new{Image = "units/player/Meta_TechnoTumblebuga.png", PosX = -21, PosY = -3, NumFrames = 4 }
	a.Meta_TechnoTumblebugw =	a.MechUnit:new{Image = "units/player/Meta_TechnoTumblebug_w.png", PosX = -19, PosY = 6 }
	a.Meta_TechnoTumblebug_broken = a.MechUnit:new{Image="units/player/Meta_TechnoTumblebug_broken.png", PosX = -21, PosY = -3 }
	a.Meta_TechnoTumblebugw_broken = a.MechUnit:new{Image="units/player/Meta_TechnoTumblebug_w_broken.png", PosX = -19, PosY = 6 }
	a.Meta_TechnoTumblebug_ns = a.MechIcon:new{Image="units/player/Meta_TechnoTumblebug_ns.png"}
	a.Meta_TechnoTumblebuge = a.MechIcon:new{Image="units/player/Meta_TechnoTumblebug_emerge.png", PosX = -21, PosY = -3, Loop = false, NumFrames = 10, Time = .07}

local files = {
	"Meta_TechnoMoth.png",
	"Meta_TechnoMotha.png",
	"Meta_TechnoMoth_w.png",
	"Meta_TechnoMoth_w_broken.png",
	"Meta_TechnoMoth_broken.png",
	"Meta_TechnoMoth_ns.png",
	"Meta_TechnoMoth_h.png",
}
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, mechPath .. file)
end
local a = ANIMS
a.Meta_TechnoMoth = a.MechUnit:new{Image="units/player/Meta_TechnoMoth.png", PosX = -17, PosY = -19, Height = 3}
a.Meta_TechnoMotha = a.MechUnit:new{Image="units/player/Meta_TechnoMotha.png", PosX = -25, PosY = -22, NumFrames = 6 }
-- a.Meta_TechnoMothw = a.MechUnit:new{Image="unitsplayer/Meta_TechnoMoth_w.png", PosX = -24, PosY = 6 }
a.Meta_TechnoMoth_broken = a.MechUnit:new{Image="units/player/Meta_TechnoMoth_broken.png", PosX = -22, PosY = -10 }
a.Meta_TechnoMothw_broken = a.MechUnit:new{Image="units/player/Meta_TechnoMoth_w_broken.png", PosX = -22, PosY = 6}
a.Meta_TechnoMoth_ns = a.MechIcon:new{Image="units/player/Meta_TechnoMoth_ns.png"}

CreatePilot{
	Id = "Pilot_Meta_TechnoDigger",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular"},
}
CreatePilot{
	Id = "Pilot_Meta_TechnoTumblebug",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular"},
}
CreatePilot{
	Id = "Pilot_Meta_TechnoMoth",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular"},
}

Meta_TechnoDigger = Pawn:new{
	Name = "Techno-Digger",

	Class = "TechnoVek",

	Health = 3,
	MoveSpeed = 4,
	Massive = true,
	Corpse = true,

	Image = "Meta_TechnoDigger",

	-- ImageOffset specifies which color scheme we will be using.
	-- (only apporpirate if you draw your mechs with Archive olive green colors)
	ImageOffset = 8,

	-- Any weapons this mech should start with goes in this table.
	SkillList = {"Meta_TechnoDiggerWeapon"},

	-- movement sounds.
	SoundLocation = "/enemy/digger_2/",

	-- who will be controlling this unit.
	DefaultTeam = TEAM_PLAYER,

	-- impact sounds.
	ImpactMaterial = IMPACT_INSECT,

}
AddPawn("Meta_TechnoDigger")

local oldMove = Move.GetTargetArea
function Move:GetTargetArea(p, ...)
	local mover = Board:GetPawn(p)
	if mover and (mover:GetType() == "Meta_TechnoDigger" or mover:GetType() == "Meta_TechnoTumblebug") then
		local pathType
		if Board:GetTerrain(p) == TERRAIN_WATER then pathType = mover:GetPathProf() else pathType = PATH_FLYER end
		local old = extract_table(Board:GetReachable(p, mover:GetMoveSpeed(), pathType))
		local ret = PointList()

		for _, v in ipairs(old) do
			local terrain = Board:GetTerrain(v)

			if terrain ~= TERRAIN_HOLE and terrain ~= TERRAIN_WATER then
				ret:push_back(v)
			end
		end

		return ret
	end

	return oldMove(self, p, ...)
end

local oldMove = Move.GetSkillEffect
function Move:GetSkillEffect(p1, p2, ...)
	local mover = Board:GetPawn(p1)
	if mover and (mover:GetType() == "Meta_TechnoDigger" or mover:GetType() == "Meta_TechnoTumblebug") then
		local ret = SkillEffect()
		local pawnId = mover:GetId()

		-- just preview move.
		-- ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1, -1))", pawnId))
		if not Board:IsTerrain(p1, TERRAIN_WATER) and not Board:IsTerrain(p2, TERRAIN_WATER) and p1:Manhattan(p2) > 1 then
		--it's annoying to go through the whole burrowing animation for one tile so we force a normal Move
		--could probably check whether it's possible to move to p2 without burrowing but this helps a little
			ret:AddBurrow(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)
			ret:AddSound("/enemy/shared/crawl_out")
			ret:AddDelay(0.7)	--burrowing anim duration
			local path = extract_table(Board:GetPath(p1, p2, PATH_FLYER))
			local dist = #path - 1
			for i = 1, #path do
				local p = path[i]
				ret:AddBounce(p, -2)
				ret:AddDelay(.32 / dist)
			end
		else
			ret:AddMove(Board:GetPath(p1, p2, mover:GetPathProf()), FULL_DELAY)
		end


		return ret
	end

	return oldMove(self, p1, p2, ...)
end

Meta_TechnoTumblebug = Pawn:new{
	Name = "Techno-Tumblebug",
	Class = "TechnoVek",
	Health = 3,
	MoveSpeed = 4,
	Massive = true,
	Corpse = true,

	-- reference the animations we set up earlier.
	Image = "Meta_TechnoTumblebug",

	-- ImageOffset specifies which color scheme we will be using.
	-- (only apporpirate if you draw your mechs with Archive olive green colors)
	ImageOffset = 8,

	-- Any weapons this mech should start with goes in this table.
	SkillList = {"Meta_TechnoTumblebugWeapon"},

	-- movement sounds.
	SoundLocation = "/enemy/dung_2/",

	-- who will be controlling this unit.
	DefaultTeam = TEAM_PLAYER,

	-- impact sounds.
	ImpactMaterial = IMPACT_INSECT,
}
AddPawn("Meta_TechnoTumblebug")

modApi:addPalette({
    ID = "Meta_Moth",
    Name = "Alpha Vek Steel Brown",
    Image = "units/player/Meta_TechnoMoth_ns.png",
    PlateHighlight = {255,226,171},
    PlateLight     = {139, 121, 164},
    PlateMid       = {85, 88, 112},
    PlateDark      = {36, 41, 65},
    PlateOutline   = {12,19,31},
    PlateShadow    = {60,87,89},
    BodyColor      = {69,116,98},
    BodyHighlight  = {79,146,107},
    }
)

Meta_TechnoMoth = Pawn:new{
	Name = "Techno-Moth",
	Class = "TechnoVek",
	Health = 2,
	MoveSpeed = 4,
	Massive = true,
	Corpse = true,
    Flying=true,
	LargeShield = true,

	-- reference the animations we set up earlier.
	Image = "Meta_TechnoMoth",

	-- ImageOffset specifies which color scheme we will be using.
	-- (only apporpirate if you draw your mechs with Archive olive green colors)
	-- ImageOffset = 8,
	ImageOffset = modApi:getPaletteImageOffset("Meta_Moth"),
	-- Any weapons this mech should start with goes in this table.
	SkillList = {"Meta_TechnoMothWeapon"},

	-- movement sounds.
	SoundLocation = "/enemy/moth_2/",

	-- who will be controlling this unit.
	DefaultTeam = TEAM_PLAYER,

	-- impact sounds.
	ImpactMaterial = IMPACT_INSECT,

}
AddPawn("Meta_TechnoMoth")
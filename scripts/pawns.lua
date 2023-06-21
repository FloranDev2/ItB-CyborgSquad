-- add color palette
local pathScripts = mod_loader.mods[modApi.currentMod].scriptPath
modApi:addPalette({
		ID = "truelch_CyborgsColor",
		Name = "Truelch's Cyborgs' Color",
		PlateHighlight = {255, 226, 171},	--lights
		PlateLight     = {200, 156, 88},	--main highlight
		PlateMid       = {121, 83, 76},		--main light
		PlateDark      = {47, 37, 53},		--main mid
		PlateOutline   = {12, 19, 31},		--main dark
		PlateShadow    = {62, 69, 93},		--metal dark
		BodyColor      = {74, 136, 163},	--metal mid
		BodyHighlight  = {206, 212, 135},	--metal light
})
local palette = modApi:getPaletteImageOffset("truelch_CyborgsColor")

-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

---------------------
--- Cyborg Pilots ---
---------------------

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

---------------------
--- Scorpion Mech ---
---------------------

-- locate our mech assets.
local scorpionPath = path.."img/mech_scorpion/"

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
	modApi:appendAsset("img/units/player/"..file, scorpionPath..file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.truelch_mech_scorpion =			a.MechUnit:new{ Image = "units/player/truelch_mech_scorpion.png",          PosX = -19, PosY = -12 }
a.truelch_mech_scorpiona =			a.MechUnit:new{ Image = "units/player/truelch_mech_scorpion_a.png",        PosX = -24, PosY = -9, NumFrames = 4 }
a.truelch_mech_scorpionw =			a.MechUnit:new{ Image = "units/player/truelch_mech_scorpion_w.png",        PosX = -17, PosY = -7 }
a.truelch_mech_scorpion_broken =	a.MechUnit:new{ Image = "units/player/truelch_mech_scorpion_broken.png",   PosX = -19, PosY = -12 }
a.truelch_mech_scorpionw_broken =	a.MechUnit:new{ Image = "units/player/truelch_mech_scorpion_w_broken.png", PosX = -17, PosY = -7 }
a.truelch_mech_scorpion_ns =		a.MechIcon:new{ Image = "units/player/truelch_mech_scorpion_ns.png", }

truelch_ScorpionMech = Pawn:new {
	Name = "Techno-Scorpion",
	Class = "TechnoVek",
	Health = 3,
	MoveSpeed = 3,
	Image = "truelch_mech_scorpion",
	ImageOffset = palette,
	SkillList = { "truelch_ScorpionAttack" },
	SoundLocation = "/enemy/scorpion_soldier_2/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
}

-------------------
-- Bouncer Mech ---
-------------------

-- locate our mech assets.
local bouncerPath = path.."img/mech_bouncer/"

-- make a list of our files.
local files = {
	"truelch_mech_bouncer.png",
	"truelch_mech_bouncer_a.png",
	"truelch_mech_bouncer_w.png",
	"truelch_mech_bouncer_broken.png",
	"truelch_mech_bouncer_w_broken.png",
	"truelch_mech_bouncer_ns.png",
	"truelch_mech_bouncer_h.png"
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, bouncerPath..file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.truelch_mech_bouncer =         a.MechUnit:new{ Image = "units/player/truelch_mech_bouncer.png",          PosX = -23, PosY = -10 }
a.truelch_mech_bouncera =        a.MechUnit:new{ Image = "units/player/truelch_mech_bouncer_a.png",        PosX = -23, PosY = -10, NumFrames = 4 }
a.truelch_mech_bouncerw =        a.MechUnit:new{ Image = "units/player/truelch_mech_bouncer_w.png",        PosX = -19, PosY = -5 }
a.truelch_mech_bouncer_broken =	 a.MechUnit:new{ Image = "units/player/truelch_mech_bouncer_broken.png",   PosX = -23, PosY = -10 }
a.truelch_mech_bouncerw_broken = a.MechUnit:new{ Image = "units/player/truelch_mech_bouncer_w_broken.png", PosX = -19, PosY = -5 }
a.truelch_mech_bouncer_ns =      a.MechIcon:new{ Image = "units/player/truelch_mech_bouncer_ns.png"}

truelch_BouncerMech = Pawn:new {
	Name = "Techno-Bouncer",
	Class = "TechnoVek",
	Health = 3,
	MoveSpeed = 3,
	Image = "truelch_mech_bouncer",
	ImageOffset = palette,
	SkillList = { "truelch_BouncerAttack" },
	SoundLocation = "/enemy/bouncer_2/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
}

---------------------
-- Burrower Mech ---
---------------------

-- locate our mech assets.
local burrowerPath = path .."img/mech_burrower/"

-- make a list of our files.
local files = {
	"truelch_mech_burrower.png",
	"truelch_mech_burrower_a.png",
	"truelch_mech_burrower_w.png",
	"truelch_mech_burrower_broken.png",
	"truelch_mech_burrower_w_broken.png",
	"truelch_mech_burrower_ns.png",
	"truelch_mech_burrower_h.png",
	"truelch_mech_burrower_emerge.png"
}

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, burrowerPath .. file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.truelch_mech_burrower =         a.MechUnit:new{ Image = "units/player/truelch_mech_burrower.png",          PosX = -18, PosY = -7 }
a.truelch_mech_burrowera =        a.MechUnit:new{ Image = "units/player/truelch_mech_burrower_a.png",        PosX = -18, PosY = -7, NumFrames = 4 }
a.truelch_mech_burrowerw =        a.MechUnit:new{ Image = "units/player/truelch_mech_burrower_w.png",        PosX = -15, PosY =  4 }
a.truelch_mech_burrower_broken =  a.MechUnit:new{ Image = "units/player/truelch_mech_burrower_broken.png",   PosX = -18, PosY = -7 }
a.truelch_mech_burrowerw_broken = a.MechUnit:new{ Image = "units/player/truelch_mech_burrower_w_broken.png", PosX = -15, PosY =  4 }
a.truelch_mech_burrower_ns =      a.MechIcon:new{ Image = "units/player/truelch_mech_burrower_ns.png"}
a.truelch_mech_burrowere =        a.MechIcon:new{ Image = "units/player/truelch_mech_burrower_emerge.png", PosX = -18, PosY = -7, Loop = false, NumFrames = 10, Time = .07}

truelch_BurrowerMech = Pawn:new {
	Name = "Techno-Burrower",
	Class = "TechnoVek",
	Health = 3,
	MoveSpeed = 4,
	Image = "truelch_mech_burrower",
	ImageOffset = palette,
	SkillList = { "truelch_BurrowerAttack" },
	SoundLocation = "/enemy/burrower_2/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_INSECT,
	Massive = true,
	Burrows = true,
	Pushable = false,
}

--Stole that from Metalocif!
local oldMove = Move.GetSkillEffect
function Move:GetSkillEffect(p1, p2, ...)
	local mover = Board:GetPawn(p1)
	if mover and (mover:GetType() == "truelch_BurrowerMech") then
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
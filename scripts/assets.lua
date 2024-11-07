local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath

--Weapons' images
modApi:appendAsset("img/weapons/truelch_bouncer_attack.png",  resourcePath .. "img/weapons/truelch_bouncer_attack.png")
modApi:appendAsset("img/weapons/truelch_burrower_attack.png", resourcePath .. "img/weapons/truelch_burrower_attack.png")
modApi:appendAsset("img/weapons/truelch_scorpion_attack.png", resourcePath .. "img/weapons/truelch_scorpion_attack.png")

--Maybe unnecessary in the end
for i = 0, 3 do
	modApi:appendAsset("img/combat/icons/truelch_arrow"..i..".png", resourcePath .. "img/combat/icons/truelch_arrow"..i..".png")
		Location["combat/icons/truelch_arrow"..i..".png"] = Point(-28, 1)

	modApi:appendAsset("img/combat/icons/truelch_arrowoff"..i..".png", resourcePath .. "img/combat/icons/truelch_arrowoff"..i..".png")
		Location["combat/icons/truelch_arrowoff"..i..".png"] = Point(-28, 1)
end

--[[
for i = 0, 5 do
	modApi:appendAsset("img/combat/icons/truelch_"..i..".png", resourcePath .. "img/combat/icons/truelch_"..i..".png")
		Location["combat/icons/truelch_"..i..".png"] = Point(-28, 1)
end
]]
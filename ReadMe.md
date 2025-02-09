# Truelch's Cyborg Squad (v1.1.2)

I'm finally releasing this squad, that was supposed to bring me back to modding some months (years?) ago.
All feedback is welcome, especially to squish these pesky Vek, I mean bugs!

## Credits
Special thanks to:
- Generic: helping me with various things, like the Bumper move animation and web immunity!
- Lemonymous: as always, scripting help (notably for the tile "un-craking" stuff)

## Description

### Scorpion Mech
It can grab nearby enemies and move with them to lure them in dangerous position! (or drown them in water)

### Bouncer Mech
Can either push an enemy or throw it into another enemy, killing the enemy with the lowest health and the.
The throw put a lot of stress on the cyborg muscles of the Bouncer, self-damaging it.

### Burrower Mech
Can sneak up to the enemy by moving underground, obstacles. Its attack deal damage to the main target, and push sideways tiles.
Can also safely target a building (without damaging it), pushing nearby enemies outward.
Due to its nature, the Burrower can withstand pushing attacks without moving (which can be handy in certain situations), but cannot go on water tiles.

## TODO
- Achievements
- Improve readibility of Scorpion's attack by displaying the current path (QoL improvement)

## Versions

### v1.1.2
- Fixed bouncer second fire mode name
- Burrower's weapon improved checks

### v1.1.1
- Bouncer's weapon improved:
  - When the sweep upgrade is enabled, the player has now the choice to use it or the regular single target mode
  - Fixed the delays between different throws; they should all happen at the same time (along with pushes too)
- Fixed an issue with a Burrower's function (to detect if crack upgrade is enabled) which would cause an error with some other mods (due to nil pawn being passed)

### v1.1.0
Added achievements:
- There can be only one: Finish a game without letting a single Bouncer, Burrower or Scorpion escape (at least one of each must have been killed during your run)
- Vek Ball: Throw an object 4 times at a Leader in a mission
- Scorpsome: Kill 4 enemies in one single Scorpion's attack

### v1.0.3
- Fixed issues with Bouncer's weapon:
  - when only one of the unit is shielded, it now removes correctly the shield and kills the other unit
  - when one of the unit can leave a corpse after dying (like Mechs but also certain enemies like the tree boss I think), the other is killed no matter what
- Just a reminder for these cases (they were already treated but it's a good reminder):
  - if both units leave corpses, the attack just become a push
  - if both units are shielded / frozen, both lose it, and then we proceed with regular damage calculation

### v1.0.2
- Fixed Scorpion's weapon logic for the path creation
- Added to the Burrower's weapon's description that it won't crack frozen water
- Changed squad's icon to fit with palette

### v1.0.1
- Fixed undo move removing crack all the time (was needed for Burrower's weapon crack upgrade)

### v1.0.0
Release! There's no achievements yet, but apart from that, the squad is mostly ready.
# Read-only. Gousi/white are all-channel independent multipliers.
execute if score @s zx.gs3p matches 1.. if score @s zx.gs3n matches 1.. run function fallendream:lib/skill_mul/pending_gousi
function fallendream:equipment/armor/glimmer/state
execute if score #gl_mode zx.meta matches 2 run function fallendream:lib/skill_mul/pending_white

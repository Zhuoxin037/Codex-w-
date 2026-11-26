# Read-only scans: no gain, expiry, consumption, damage or mana APIs.
function fallendream:upgrade/api/dmg_held
execute if score @s zx.cy_mmn matches 1.. run function fallendream:lib/skill_mul/pending_cy
execute if score @s zx.dio_emp matches 1.. run function fallendream:lib/skill_mul/pending_dio
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] unless entity @s[tag=!zx.mv_ny,tag=!zx.mv_ny2] run function fallendream:lib/skill_mul/pending_mv
function fallendream:equipment/armor/profile/put_bonus
function fallendream:equipment/armor/ebb_tide/put_bonus
function fallendream:equipment/armor/glimmer/hook_add
execute store result storage zx:work bgc.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work bgc.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work bgc.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work bgc.u3 int 1 run scoreboard players get @s manacore.u3
execute at @s run function fallendream:equipment/staff/begonia/emp_find with storage zx:work bgc

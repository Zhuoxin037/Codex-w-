# Read-only scans: no gain, expiry, consumption, damage or mana APIs.
function sweetdream:upgrade/api/dmg_held
execute if score @s zx.cy_mmn matches 1.. run function sweetdream:lib/skill_mul/pending_cy
execute if score @s zx.dio_emp matches 1.. run function sweetdream:lib/skill_mul/pending_dio
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] if entity @s[tag=zx.mv_ny] run function sweetdream:lib/skill_mul/pending_mv
function sweetdream:equipment/armor/profile/put_bonus
function sweetdream:equipment/armor/ebb_tide/put_bonus
function sweetdream:equipment/armor/glimmer/hook_add
execute store result storage zx:work bgc.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work bgc.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work bgc.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work bgc.u3 int 1 run scoreboard players get @s manacore.u3
execute at @s run function sweetdream:equipment/staff/begonia/emp_find with storage zx:work bgc

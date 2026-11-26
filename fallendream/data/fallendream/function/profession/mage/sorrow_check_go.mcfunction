$data modify storage zx:work jcheck.skill set value "$(skill)"
scoreboard players set @s zx.j_cast_a 0
execute if data storage zx:work jcheck{skill:"fallendream:ap_attack"} run scoreboard players set @s zx.j_cast_a 1
execute if data storage zx:work jcheck{skill:"fallendream:wo_attack"} run scoreboard players set @s zx.j_cast_a 1
execute if data storage zx:work jcheck{skill:"fallendream:mana_crystal_attack"} run scoreboard players set @s zx.j_cast_a 1
execute if data storage zx:work jcheck{skill:"fallendream:foresight_attack"} run scoreboard players set @s zx.j_cast_a 1
execute if data storage zx:work jcheck{skill:"fallendream:self_mind_attack"} run scoreboard players set @s zx.j_cast_a 1
execute if data storage zx:work jcheck{skill:"fallendream:indwell_attack"} run scoreboard players set @s zx.j_cast_a 1

$execute if data storage zx:skills basic."$(skill)" run scoreboard players set @s zx.j_cast_a 1
execute if score @s zx.j_cast_a matches 1 run return 0
execute store result score #jcheckcost zx.meta run data get storage manacore:work a.mana 1000
scoreboard players add #jcheckcost zx.meta 80000
execute store result storage manacore:work a.mana double 0.001 run scoreboard players get #jcheckcost zx.meta

execute unless data storage zx:work hit_success_stack[-1].s2_measure run return 0
execute unless data storage zx:work hit_success_stack[-1].result{ok:1b} run return 0
execute store result score #s2_veil_before zx.meta run data get storage zx:work hit_success_stack[-1].s2_measure.hp
execute store result score #s2_veil_abs zx.meta run data get storage zx:work hit_success_stack[-1].s2_measure.ab
scoreboard players operation #s2_veil_before zx.meta += #s2_veil_abs zx.meta
scoreboard players set #s2_veil_after zx.meta 0
scoreboard players set #s2_veil_abs zx.meta 0
execute store result score #s2_veil_after zx.meta run data get entity @s Health 1000
execute store result score #s2_veil_abs zx.meta run data get entity @s AbsorptionAmount 1000
scoreboard players operation #s2_veil_before zx.meta -= #s2_veil_after zx.meta
scoreboard players operation #s2_veil_before zx.meta -= #s2_veil_abs zx.meta
execute unless score #s2_veil_before zx.meta matches 1.. run return 0
data modify storage zx:work ub set from storage zx:work hit_success_stack[-1].s2_source
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function fallendream:equipment/armor/rebirth_veil/add

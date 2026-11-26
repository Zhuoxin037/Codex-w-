execute unless entity @a[scores={zx.job=4,zx.j_form=0,zx.j_reborn=1..}] run return 0
execute if data storage zx:work hit_success_stack[-1].s2_source{src:"enemy"} run return 0
data modify storage zx:work ub set from storage zx:work hit_success_stack[-1].s2_source
function fallendream:lib/u_by
scoreboard players set #s2_veil_open zx.meta 0
execute as @a[tag=zx.ub,limit=1,scores={zx.job=4,zx.j_form=0,zx.j_reborn=1..}] if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run scoreboard players set #s2_veil_open zx.meta 1
execute if score #s2_veil_open zx.meta matches 1 run function fallendream:equipment/armor/rebirth_veil/before

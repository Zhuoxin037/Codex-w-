scoreboard players set #s2_echo_ok zx.meta 0
execute store result score #s2_echo_ok zx.meta run data get storage zx:b21 echo_stack[-1].ok
data remove storage zx:b21 echo_stack[-1]
execute unless score #s2_echo_ok zx.meta matches 1 run return 0
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=3},limit=1] run return 0
execute as @a[tag=zx.ub,scores={zx.job=3},limit=1] if items entity @s weapon.offhand *[custom_data~{zx:["echo_harmony"]}] positioned ~ ~ ~ run function fallendream:equipment/tool/echo_harmony/give_all

# 原版手持模型每两刻切一帧，32 帧循环为 3.2 秒；静态斧身不重复切换。
# 光柱只处理存在的实体；锁定维度，避免三维度扫描重复处理同一根柱子。
execute in minecraft:overworld as @e[type=minecraft:item_display,tag=zx.ac_beam,distance=0..] run function sweetdream:equipment/axe/angel_core/visual/beam_anim
execute in minecraft:the_nether as @e[type=minecraft:item_display,tag=zx.ac_beam,distance=0..] run function sweetdream:equipment/axe/angel_core/visual/beam_anim
execute in minecraft:the_end as @e[type=minecraft:item_display,tag=zx.ac_beam,distance=0..] run function sweetdream:equipment/axe/angel_core/visual/beam_anim
scoreboard players add #tick zx.acvf 1
execute if score #tick zx.acvf matches ..1 run return 0
scoreboard players set #tick zx.acvf 0
scoreboard players add #frame zx.acvf 1
execute if score #frame zx.acvf matches 32.. run scoreboard players set #frame zx.acvf 0
data modify storage zx:work angel_visual set value {frame:0}
execute store result storage zx:work angel_visual.frame int 1 run scoreboard players get #frame zx.acvf
# 两只手分别处理；暂存返还窗口不写物品，避免与强化台返还覆盖互相干扰。
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["angel_core"]}] run function sweetdream:equipment/axe/angel_core/visual/apply with storage zx:work angel_visual
execute as @a[tag=!test_pending_return] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["angel_core"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["angel_core"]}] run function sweetdream:equipment/axe/angel_core/visual/apply with storage zx:work angel_visual

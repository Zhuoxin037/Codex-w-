# 玩家自身 at @s 可在三维度取到正确上下文；实体租期逐维度只扣一次。
execute as @a[tag=!test_pending_return] at @s run function sweetdream:equipment/staff/triad/visual/watch
execute in minecraft:overworld as @e[type=minecraft:item_display,tag=zx.tv_missile,distance=0..] run function sweetdream:equipment/staff/triad/visual/lease
execute in minecraft:the_nether as @e[type=minecraft:item_display,tag=zx.tv_missile,distance=0..] run function sweetdream:equipment/staff/triad/visual/lease
execute in minecraft:the_end as @e[type=minecraft:item_display,tag=zx.tv_missile,distance=0..] run function sweetdream:equipment/staff/triad/visual/lease

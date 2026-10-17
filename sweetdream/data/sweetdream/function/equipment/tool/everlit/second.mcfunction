# 长明的GUI绑定与灯灵生命周期分别管理。
execute as @a[tag=!test_pending_return] run function sweetdream:equipment/tool/everlit/model_sync
# 持有者集合与“已被一只灯认领”的集合分离。scratch el_own 不会清掉别人的认领。
tag @a[tag=zx.el_host] remove zx.el_host
tag @a[tag=zx.el_seen] remove zx.el_seen
tag @a[tag=zx.el_own] remove zx.el_own
execute as @a unless entity @s[nbt={Health:0.0f}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["everlit"]}] run tag @s add zx.el_host
execute in minecraft:overworld as @e[type=minecraft:marker,tag=zx.el_wisp,distance=0..] at @s run function sweetdream:equipment/tool/everlit/wisp_tick_dispatch
execute in minecraft:overworld as @e[type=minecraft:item_display,tag=zx.el_visual,distance=0..] at @s run function sweetdream:equipment/tool/everlit/visual/keep
execute in minecraft:the_nether as @e[type=minecraft:marker,tag=zx.el_wisp,distance=0..] at @s run function sweetdream:equipment/tool/everlit/wisp_tick_dispatch
execute in minecraft:the_nether as @e[type=minecraft:item_display,tag=zx.el_visual,distance=0..] at @s run function sweetdream:equipment/tool/everlit/visual/keep
execute in minecraft:the_end as @e[type=minecraft:marker,tag=zx.el_wisp,distance=0..] at @s run function sweetdream:equipment/tool/everlit/wisp_tick_dispatch
execute in minecraft:the_end as @e[type=minecraft:item_display,tag=zx.el_visual,distance=0..] at @s run function sweetdream:equipment/tool/everlit/visual/keep
execute as @a[tag=zx.el_host,tag=!zx.el_seen] at @s run function sweetdream:equipment/tool/everlit/make

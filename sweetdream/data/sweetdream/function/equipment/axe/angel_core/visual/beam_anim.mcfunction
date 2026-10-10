# 只处理新光柱；旧实体交给 beam_tick 清理。
execute unless score @s zx.ab_age matches 0.. run return 0
scoreboard players add @s zx.ab_age 1
# 起柱时同步补偿 Y 平移，使柱底一直贴地，避免柱子从半空长出来。
execute if score @s zx.ab_age matches 2 run data modify entity @s transformation.translation set value [0.0f,0.0f,0.0f]
execute if score @s zx.ab_age matches 2 run data modify entity @s transformation.scale set value [1.0f,6.0f,1.0f]
execute if score @s zx.ab_age matches 2 run data modify entity @s start_interpolation set value 0
# 最后八刻收束为光丝，再销毁；全程不参与目标、伤害和圣痕判定。
execute if score @s zx.ab_age matches 32 run data modify entity @s interpolation_duration set value 8
execute if score @s zx.ab_age matches 32 run data modify entity @s transformation.scale set value [0.04f,6.0f,0.04f]
execute if score @s zx.ab_age matches 32 run data modify entity @s start_interpolation set value 0
execute if score @s zx.ab_age matches 40.. run kill @s

# 每四刻插值到下一个四元数；每个领域仍然只使用一个 item_display。
scoreboard players add #domain_clock zx.vfx_t 1
execute if score #domain_clock zx.vfx_t matches ..3 run return 0
scoreboard players set #domain_clock zx.vfx_t 0
execute in minecraft:overworld unless entity @e[type=minecraft:item_display,tag=zx.tc_dom,distance=0..] in minecraft:the_nether unless entity @e[type=minecraft:item_display,tag=zx.tc_dom,distance=0..] in minecraft:the_end unless entity @e[type=minecraft:item_display,tag=zx.tc_dom,distance=0..] run return 0
scoreboard players add #domain_phase zx.vfx_t 1
execute if score #domain_phase zx.vfx_t matches 48.. run scoreboard players set #domain_phase zx.vfx_t 0
data modify storage zx:work domain_turn set value {phase:0}
execute store result storage zx:work domain_turn.phase int 1 run scoreboard players get #domain_phase zx.vfx_t
function sweetdream:visual/domain_select with storage zx:work domain_turn
execute in minecraft:overworld as @e[type=minecraft:item_display,tag=zx.tc_dom,distance=0..] run function sweetdream:visual/domain_apply
execute in minecraft:the_nether as @e[type=minecraft:item_display,tag=zx.tc_dom,distance=0..] run function sweetdream:visual/domain_apply
execute in minecraft:the_end as @e[type=minecraft:item_display,tag=zx.tc_dom,distance=0..] run function sweetdream:visual/domain_apply

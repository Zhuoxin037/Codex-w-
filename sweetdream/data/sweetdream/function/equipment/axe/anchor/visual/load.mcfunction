# 沉锚原生几何/动作接入；不改变技能伤害、费用、冷却和拉近速度。
execute unless data storage zx:config obj_zx_av_t run scoreboard objectives add zx.av_t dummy
execute unless data storage zx:config obj_zx_av_t run data modify storage zx:config obj_zx_av_t set value 1b
execute unless data storage zx:config obj_zx_av_phase run scoreboard objectives add zx.av_phase dummy
execute unless data storage zx:config obj_zx_av_phase run data modify storage zx:config obj_zx_av_phase set value 1b
execute unless data storage zx:config obj_zx_av_slot run scoreboard objectives add zx.av_slot dummy
execute unless data storage zx:config obj_zx_av_slot run data modify storage zx:config obj_zx_av_slot set value 1b
execute unless data storage zx:config obj_zx_av_hand run scoreboard objectives add zx.av_hand dummy
execute unless data storage zx:config obj_zx_av_hand run data modify storage zx:config obj_zx_av_hand set value 1b
execute unless data storage zx:config obj_zx_av_dim run scoreboard objectives add zx.av_dim dummy
execute unless data storage zx:config obj_zx_av_dim run data modify storage zx:config obj_zx_av_dim set value 1b
execute unless data storage zx:config obj_zx_av_life run scoreboard objectives add zx.av_life dummy
execute unless data storage zx:config obj_zx_av_life run data modify storage zx:config obj_zx_av_life set value 1b
execute as @a[tag=zx.av_cast] at @s run function sweetdream:equipment/axe/anchor/visual/end
scoreboard players set @a zx.an_pull 0
data remove storage zx:anchor players
data modify storage zx:anchor floor set value [880,736,649,649,649,681,758,784,704,551,388,315,354,377,382,386,388,389,390,390,390,390]
# ★ 沉锚"锁定"标签兜底清洗(2026-10-23): 三维度各清一遍, 免得上一局残留的
#   zx.an_lock 挂在怪身上(/reload / 进世界都会走这里)。
execute in minecraft:overworld run tag @e[tag=zx.an_lock,distance=0..] remove zx.an_lock
execute in minecraft:the_nether run tag @e[tag=zx.an_lock,distance=0..] remove zx.an_lock
execute in minecraft:the_end run tag @e[tag=zx.an_lock,distance=0..] remove zx.an_lock
execute in minecraft:overworld run kill @e[type=minecraft:item_display,tag=zx.av_anchor,distance=0..]
execute in minecraft:the_nether run kill @e[type=minecraft:item_display,tag=zx.av_anchor,distance=0..]
execute in minecraft:the_end run kill @e[type=minecraft:item_display,tag=zx.av_anchor,distance=0..]

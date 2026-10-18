# 仅三形态视觉；不重置原 tri_form / tri_strong / tri_next。
execute unless data storage zx:config obj_zx_tv_t run scoreboard objectives add zx.tv_t dummy
execute unless data storage zx:config obj_zx_tv_t run data modify storage zx:config obj_zx_tv_t set value 1b
execute unless data storage zx:config obj_zx_tv_slot run scoreboard objectives add zx.tv_slot dummy
execute unless data storage zx:config obj_zx_tv_slot run data modify storage zx:config obj_zx_tv_slot set value 1b
execute unless data storage zx:config obj_zx_tv_hand run scoreboard objectives add zx.tv_hand dummy
execute unless data storage zx:config obj_zx_tv_hand run data modify storage zx:config obj_zx_tv_hand set value 1b
execute unless data storage zx:config obj_zx_tv_form run scoreboard objectives add zx.tv_form dummy
execute unless data storage zx:config obj_zx_tv_form run data modify storage zx:config obj_zx_tv_form set value 1b
execute unless data storage zx:config obj_zx_tv_age run scoreboard objectives add zx.tv_age dummy
execute unless data storage zx:config obj_zx_tv_age run data modify storage zx:config obj_zx_tv_age set value 1b
execute unless data storage zx:config obj_zx_tv_life run scoreboard objectives add zx.tv_life dummy
execute unless data storage zx:config obj_zx_tv_life run data modify storage zx:config obj_zx_tv_life set value 1b
execute as @a[tag=zx.tv_cast] run function sweetdream:equipment/staff/triad/visual/end
execute in minecraft:overworld run kill @e[type=minecraft:item_display,tag=zx.tv_missile,distance=0..]
execute in minecraft:the_nether run kill @e[type=minecraft:item_display,tag=zx.tv_missile,distance=0..]
execute in minecraft:the_end run kill @e[type=minecraft:item_display,tag=zx.tv_missile,distance=0..]

# 纯表现账本；不改技能计时、伤害、弹药和归属。
execute unless data storage zx:config obj_zx_bv_t run scoreboard objectives add zx.bv_t dummy
execute unless data storage zx:config obj_zx_bv_t run data modify storage zx:config obj_zx_bv_t set value 1b
execute unless data storage zx:config obj_zx_bv_charge run scoreboard objectives add zx.bv_charge dummy
execute unless data storage zx:config obj_zx_bv_charge run data modify storage zx:config obj_zx_bv_charge set value 1b
execute unless data storage zx:config obj_zx_bv_seek run scoreboard objectives add zx.bv_seek dummy
execute unless data storage zx:config obj_zx_bv_seek run data modify storage zx:config obj_zx_bv_seek set value 1b
execute unless data storage zx:config obj_zx_bv_age run scoreboard objectives add zx.bv_age dummy
execute unless data storage zx:config obj_zx_bv_age run data modify storage zx:config obj_zx_bv_age set value 1b
execute unless data storage zx:config obj_zx_bv_back run scoreboard objectives add zx.bv_back dummy
execute unless data storage zx:config obj_zx_bv_back run data modify storage zx:config obj_zx_bv_back set value 1b
execute unless data storage zx:config obj_zx_bv_state run scoreboard objectives add zx.bv_state dummy
execute unless data storage zx:config obj_zx_bv_state run data modify storage zx:config obj_zx_bv_state set value 1b
execute in minecraft:overworld run kill @e[tag=zx.bv_display,distance=0..]
execute in minecraft:the_nether run kill @e[tag=zx.bv_display,distance=0..]
execute in minecraft:the_end run kill @e[tag=zx.bv_display,distance=0..]
scoreboard players set @a zx.bv_t 16
scoreboard players set @a zx.bv_back 0
scoreboard players set @a zx.bv_seek 0

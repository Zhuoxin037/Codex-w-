# 灯灵模型状态；每个计分项属于逻辑 marker，不使用共享的玩家状态。
execute unless data storage zx:config obj_zx_el_clock run scoreboard objectives add zx.el_clock dummy
execute unless data storage zx:config obj_zx_el_clock run data modify storage zx:config obj_zx_el_clock set value 1b
execute unless data storage zx:config obj_zx_el_state run scoreboard objectives add zx.el_state dummy
execute unless data storage zx:config obj_zx_el_state run data modify storage zx:config obj_zx_el_state set value 1b
execute unless data storage zx:config obj_zx_el_time run scoreboard objectives add zx.el_time dummy
execute unless data storage zx:config obj_zx_el_time run data modify storage zx:config obj_zx_el_time set value 1b
execute unless data storage zx:config obj_zx_el_attack run scoreboard objectives add zx.el_attack dummy
execute unless data storage zx:config obj_zx_el_attack run data modify storage zx:config obj_zx_el_attack set value 1b
execute unless data storage zx:config obj_zx_el_mana run scoreboard objectives add zx.el_mana dummy
execute unless data storage zx:config obj_zx_el_mana run data modify storage zx:config obj_zx_el_mana set value 1b
execute unless data storage zx:config obj_zx_el_last run scoreboard objectives add zx.el_last dummy
execute unless data storage zx:config obj_zx_el_last run data modify storage zx:config obj_zx_el_last set value 1b
execute unless data storage zx:config obj_zx_el_dim run scoreboard objectives add zx.el_dim dummy
execute unless data storage zx:config obj_zx_el_dim run data modify storage zx:config obj_zx_el_dim set value 1b
scoreboard players set #el_2 zx.meta 2
scoreboard players set #el_4 zx.meta 4
scoreboard players set #el_80 zx.meta 80

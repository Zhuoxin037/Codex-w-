# 五世恶咒视觉专用：只注册表现计分项，不改世咒、魔力、伤害或冷却。
execute unless data storage zx:config obj_zx_fcvv_i run scoreboard objectives add zx.fcvv_i dummy
execute unless data storage zx:config obj_zx_fcvv_i run data modify storage zx:config obj_zx_fcvv_i set value 1b
execute unless data storage zx:config obj_zx_fcvv_s run scoreboard objectives add zx.fcvv_s dummy
execute unless data storage zx:config obj_zx_fcvv_s run data modify storage zx:config obj_zx_fcvv_s set value 1b
execute unless data storage zx:config obj_zx_fcvv_m run scoreboard objectives add zx.fcvv_m dummy
execute unless data storage zx:config obj_zx_fcvv_m run data modify storage zx:config obj_zx_fcvv_m set value 1b
execute unless data storage zx:config obj_zx_fcvv_h run scoreboard objectives add zx.fcvv_h dummy
execute unless data storage zx:config obj_zx_fcvv_h run data modify storage zx:config obj_zx_fcvv_h set value 1b
execute unless data storage zx:config obj_zx_fcvv_slot run scoreboard objectives add zx.fcvv_slot dummy
execute unless data storage zx:config obj_zx_fcvv_slot run data modify storage zx:config obj_zx_fcvv_slot set value 1b
execute unless data storage zx:config obj_zx_fcvv_d run scoreboard objectives add zx.fcvv_d dummy
execute unless data storage zx:config obj_zx_fcvv_d run data modify storage zx:config obj_zx_fcvv_d set value 1b
execute unless data storage zx:config obj_zx_fcvv_f run scoreboard objectives add zx.fcvv_f dummy
execute unless data storage zx:config obj_zx_fcvv_f run data modify storage zx:config obj_zx_fcvv_f set value 1b
scoreboard players set #fcvv_four zx.fcvv_f 4
scoreboard players add @a zx.fcvv_i 0
execute as @a[tag=zx.fcvv_on] at @s run function sweetdream:equipment/staff/five_curses/visual/end

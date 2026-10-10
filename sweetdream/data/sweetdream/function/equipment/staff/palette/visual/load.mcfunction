execute unless data storage zx:config obj_zx_pv_age run scoreboard objectives add zx.pv_age dummy
data modify storage zx:config obj_zx_pv_age set value 1b
execute unless data storage zx:config obj_zx_pv_idle run scoreboard objectives add zx.pv_idle dummy
data modify storage zx:config obj_zx_pv_idle set value 1b
execute unless data storage zx:config obj_zx_pv_c1 run scoreboard objectives add zx.pv_c1 dummy
data modify storage zx:config obj_zx_pv_c1 set value 1b
execute unless data storage zx:config obj_zx_pv_c2 run scoreboard objectives add zx.pv_c2 dummy
data modify storage zx:config obj_zx_pv_c2 set value 1b
execute unless data storage zx:config obj_zx_pv_f run scoreboard objectives add zx.pv_f dummy
data modify storage zx:config obj_zx_pv_f set value 1b
execute unless data storage zx:config obj_zx_pv_spin run scoreboard objectives add zx.pv_spin dummy
data modify storage zx:config obj_zx_pv_spin set value 1b
scoreboard players set #4 zx.pv_f 4
scoreboard players set #32 zx.pv_f 32
execute unless data storage zx:config obj_zx_pv_wait run scoreboard objectives add zx.pv_wait dummy
data modify storage zx:config obj_zx_pv_wait set value 1b

scoreboard players set #tf_wave zx.meta 0
execute positioned ^-4 ^ ^ if entity @e[tag=zx.et_wave,distance=..2.5,limit=1] run scoreboard players set #tf_wave zx.meta 1
execute positioned ^-2 ^ ^ if entity @e[tag=zx.et_wave,distance=..2.5,limit=1] run scoreboard players set #tf_wave zx.meta 1
execute if entity @e[tag=zx.et_wave,distance=..2.5,limit=1] run scoreboard players set #tf_wave zx.meta 1
execute positioned ^2 ^ ^ if entity @e[tag=zx.et_wave,distance=..2.5,limit=1] run scoreboard players set #tf_wave zx.meta 1
execute positioned ^4 ^ ^ if entity @e[tag=zx.et_wave,distance=..2.5,limit=1] run scoreboard players set #tf_wave zx.meta 1
execute unless score #tf_wave zx.meta matches 1 run return 0
function sweetdream:equipment/armor/tide_fold/expand with storage zx:work tf

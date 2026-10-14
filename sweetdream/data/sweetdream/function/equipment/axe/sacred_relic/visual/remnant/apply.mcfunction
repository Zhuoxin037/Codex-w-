# 只写改变的第一项 floats；保留五个独立 flags。显式 float，避免 dispatch 失效。
execute if score @s zx.srm_last = #srm_frame zx.srm_f run return 0
data modify storage zx:srvis frames set value [0.0f]
execute store result storage zx:srvis frames[0] float 1 run scoreboard players get #srm_frame zx.srm_f
data modify entity @s item.components."minecraft:custom_model_data".floats set from storage zx:srvis frames
scoreboard players operation @s zx.srm_last = #srm_frame zx.srm_f

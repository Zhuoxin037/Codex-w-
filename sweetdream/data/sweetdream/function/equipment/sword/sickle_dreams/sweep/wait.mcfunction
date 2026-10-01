# 最多等四次 tick；不依赖两个 consume_item 进度回调的先后顺序。
execute if data storage zx:sweep current{wait:4} run return run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
execute store result score #wait zx.meta run data get storage zx:sweep current.wait
scoreboard players add #wait zx.meta 1
execute store result storage zx:sweep current.wait int 1 run scoreboard players get #wait zx.meta
data modify storage zx:sweep record set from storage zx:sweep current
function sweetdream:equipment/sword/sickle_dreams/sweep/save with storage zx:sweep ctx
execute if entity @s[tag=test_pending_return] run return 0
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sickle_dreams"]}] run return 0
$item modify entity @s weapon.mainhand {function:"minecraft:set_custom_data",tag:"{sd_sweep:$(id)}"}
item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sickle"}}
scoreboard players set @s zx.sd_t 0

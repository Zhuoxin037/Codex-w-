# 最多等四次 tick；不依赖两个 consume_item 进度回调的先后顺序。
# 【宏参数】zx:sweep current {…, hand, id} —— hand 就是这一下用的那只手
#   (weapon.mainhand / weapon.offhand)。副手支持就是把这里所有写死的
#   weapon.mainhand 换成 $(hand); 别的地方一个字不用改。
execute if data storage zx:sweep current{wait:4} run return run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
execute store result score #wait zx.meta run data get storage zx:sweep current.wait
scoreboard players add #wait zx.meta 1
execute store result storage zx:sweep current.wait int 1 run scoreboard players get #wait zx.meta
data modify storage zx:sweep record set from storage zx:sweep current
function sweetdream:equipment/sword/sickle_dreams/sweep/save with storage zx:sweep ctx
execute if entity @s[tag=test_pending_return] run return 0
$execute unless items entity @s $(hand) *[minecraft:custom_data~{zx:["sickle_dreams"]}] run return 0
$item modify entity @s $(hand) {function:"minecraft:set_custom_data",tag:"{sd_sweep:$(id)}"}
$item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sickle"}}
scoreboard players set @s zx.sd_t 0

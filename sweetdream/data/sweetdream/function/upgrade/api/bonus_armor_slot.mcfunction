# ============================================================
# sweetdream:upgrade/api/bonus_armor_slot —— 扫一个穿戴槽的升级(宏 {slot})
# ------------------------------------------------------------
# 【为什么走宏】槽位名要拼进 NBT 路径 equipment.$(slot).…, 只能宏。
# 【为什么每次先 set 0】槽位空着 / 这件没有 up 字段时 data get 会失败,
#   store 不执行 -> 分数留着上一次的值 -> 会把上一件的升级重复算一遍。
# ============================================================

scoreboard players set #up_have zx.meta 0
$execute store result score #up_have zx.meta run data get entity @s equipment.$(slot).components."minecraft:custom_data".up

$execute if score #up_have zx.meta matches 1.. run data modify storage zx:work up.id set from entity @s equipment.$(slot).components."minecraft:custom_data".up[0]
execute if score #up_have zx.meta matches 1.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
$execute if score #up_have zx.meta matches 2.. run data modify storage zx:work up.id set from entity @s equipment.$(slot).components."minecraft:custom_data".up[1]
execute if score #up_have zx.meta matches 2.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
$execute if score #up_have zx.meta matches 3.. run data modify storage zx:work up.id set from entity @s equipment.$(slot).components."minecraft:custom_data".up[2]
execute if score #up_have zx.meta matches 3.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up
$execute if score #up_have zx.meta matches 4.. run data modify storage zx:work up.id set from entity @s equipment.$(slot).components."minecraft:custom_data".up[3]
execute if score #up_have zx.meta matches 4.. run function sweetdream:upgrade/api/bonus_one with storage zx:work up

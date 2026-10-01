# ============================================================
# sweetdream:upgrade/api/fit —— 这把(主手握着的)武器能不能装这个升级
# ------------------------------------------------------------
# 【入参】zx:work up {id, cat}  —— cat 从定义表读出来一起传(拼选择器只能走宏)
# 【出参】zx:out r = {ok:1b/0b, reason:"no_def|no_weapon|cat|full|dup"}
# 【五条规则】①定义存在 ②手上是本包物品 ③类别匹配 ④槽位没满(最多2) ⑤不重复
# 【为什么读 SelectedItem】主手物品就在玩家自己的 NBT 里, 读它最省事。
# ============================================================

data modify storage zx:out r set value {ok:0b,reason:""}
$execute unless data storage zx:config updef."$(id)" run data modify storage zx:out r.reason set value "no_def"
$execute unless data storage zx:config updef."$(id)" run return 0
$execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["$(cat)"]}] run data modify storage zx:out r.reason set value "no_weapon"
$execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["$(cat)"]}] run return 0

scoreboard players set #up_have zx.meta 0
execute store result score #up_have zx.meta run data get entity @s SelectedItem.components."minecraft:custom_data".up
execute if score #up_have zx.meta matches 2.. run data modify storage zx:out r.reason set value "full"
execute if score #up_have zx.meta matches 2.. run return 0
$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{up:["$(id)"]}] run data modify storage zx:out r.reason set value "dup"
$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{up:["$(id)"]}] run return 0
data modify storage zx:out r.ok set value 1b

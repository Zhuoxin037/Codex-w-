# ============================================================
# sweetdream:upgrade/api/fit —— 副手这件装备能不能装这个升级
# ------------------------------------------------------------
# 【入参】zx:work st {id, cat}  —— cat 从定义表读出来一起传(拼选择器只能走宏)
# 【出参】zx:out r = {ok:1b/0b, reason:"no_def|cat|full|dup|req"}
# 【判定顺序】①定义存在 ②类别匹配(cat 或 cat2) ③槽位没满(最多4)
#             ④不重复 ⑤前置升级已在身上(req)
#
# 【★ 为什么读 offhand 而不是 mainhand ★】
#   敲的流程是"材料拿在主手右键消耗、要敲的装备拿在副手"(见 station/api/apply) ——
#   主手此时是**升级石自己**, 拿它去匹配类别永远匹配不上。
#   早期版本这里读的是 mainhand(等于这个功能从来没成功过), 现在修正为副手。
#   顺带: 副手物品的 NBT 路径在 1.21.5 是 equipment.offhand(不在 Inventory 里)。
#
# 【为什么类别要支持两个】像"剑、斧"这种一条升级吃两类的需求,
#   定义表里填 cat + cat2, 这里两个都试一遍(用计分板做 OR)。
#   cat2 为空时 `zx:[""]` 匹配不到任何东西, 不会误判。
#
# 【为什么槽位上限是 4】α -> β -> Ω 三级链条要占三个槽(每条都得留在列表里,
#   req 校验要查"身上有没有 α"), 原来的 2 个槽装不下一条完整链。
# ============================================================

data modify storage zx:out r set value {ok:0b,reason:""}

# ① 定义存在吗
$execute unless data storage zx:config updef."$(id)" run data modify storage zx:out r.reason set value "no_def"
$execute unless data storage zx:config updef."$(id)" run return 0

# ② 类别匹配(cat 或 cat2)
scoreboard players set #up_catok zx.meta 0
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(cat)"]}] run scoreboard players set #up_catok zx.meta 1
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(cat2)"]}] run scoreboard players set #up_catok zx.meta 1
execute if score #up_catok zx.meta matches 0 run data modify storage zx:out r.reason set value "cat"
execute if score #up_catok zx.meta matches 0 run return 0

# ③ 槽位没满(最多 4) —— 读不到就是 0 条(先归零, 否则会留着上一次的分数)
scoreboard players set #up_have zx.meta 0
execute store result score #up_have zx.meta run data get entity @s equipment.offhand.components."minecraft:custom_data".up
execute if score #up_have zx.meta matches 4.. run data modify storage zx:out r.reason set value "full"
execute if score #up_have zx.meta matches 4.. run return 0

# ④ 不重复
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{up:["$(id)"]}] run data modify storage zx:out r.reason set value "dup"
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{up:["$(id)"]}] run return 0

# ⑤ 前置升级(α -> β -> Ω): 定义表里的 req 不是空就必须已经在身上
$data modify storage zx:work up.req set from storage zx:config updef."$(id)".req
function sweetdream:upgrade/api/fit_req with storage zx:work up
execute if score #up_reqbad zx.meta matches 1 run data modify storage zx:out r.reason set value "req"
execute if score #up_reqbad zx.meta matches 1 run return 0

data modify storage zx:out r.ok set value 1b

# ============================================================
# sweetdream:upgrade/api/fit —— 副手这件装备能不能装这个升级
# ------------------------------------------------------------
# 【入参】zx:work st {id, cat, cat2, cat3, cat4}  —— 类别词从定义表读出来一起传(拼选择器只能走宏)
# 【出参】zx:out r = {ok:1b/0b, reason:"no_def|cat|full|dup|req"}
# 【判定顺序】①定义存在 ②类别匹配(cat~cat4 任一) ③槽位(2 个自由槽, 同系替换)
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
# 【★ cat3 / cat4(2026-10-07 扩) ★】冷却剂吃 剑/斧/法杖、愿景吃 剑/斧/弓/法杖 ——
#   3~4 类装不下 cat/cat2, 于是顺着再加两格, 同样是 OR。
#   ⚠️ 这两条宏行要求 st 里 cat3/cat4 **一定有绑定值**: apply/<id> 从定义表读,
#      没填的由 station/api/apply 补空串(否则"宏参数没绑"会作废整个 fit)。
#
# 【槽位模型(2026-10-07 改)】以前是"敲一条占一槽, 上限 4"(链条要占 3 槽);
#   现在按玩家口径改成 **2 个自由槽**: 一个系列占一槽, 高级替换低级只留一条,
#   最多装 2 个不同系列。替换的落地在 apply_go 调的 up_rebuild(保留非本系条目
#   + 追加新条目); 本函数只负责"这个系统能不能装"。
# ============================================================

data modify storage zx:out r set value {ok:0b,reason:""}

# ① 定义存在吗
$execute unless data storage zx:config updef."$(id)" run data modify storage zx:out r.reason set value "no_def"
$execute unless data storage zx:config updef."$(id)" run return 0

# ② 类别匹配(cat / cat2 / cat3 / cat4, 任一命中即可)
scoreboard players set #up_catok zx.meta 0
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(cat)"]}] run scoreboard players set #up_catok zx.meta 1
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(cat2)"]}] run scoreboard players set #up_catok zx.meta 1
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(cat3)"]}] run scoreboard players set #up_catok zx.meta 1
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["$(cat4)"]}] run scoreboard players set #up_catok zx.meta 1
execute if score #up_catok zx.meta matches 0 run data modify storage zx:out r.reason set value "cat"
execute if score #up_catok zx.meta matches 0 run return 0

# ③ 槽位(2026-10-07 改: **2 个自由槽**, 同系升级替换原槽、不占新槽)
#   【玩家口径】"每个装备都有两个槽位可以自由升级" —— 一个系列占一槽(高级覆盖
#     低级, 只留一条), 最多装 2 个不同系列。
#   【怎么判"同系已在"】up 列表里存的是**石头 id**(不是系列名), 字符串没法直接
#     比较 —— 先把副手身上每条 id 的系列名记成 seen."<series>" 键集(逐条宏),
#     再看新手头的系列在不在键集里(动态键, 也得宏)。两条链: ser_mark -> ser_put。
#   【同系已在时】
#     · 一级石头(req 空) -> 本系列已经有更高阶, 不能往回敲/重敲 -> 拒 "serdup"
#     · 高阶石头 -> 放行(敲入时 up_rebuild 会把同系旧条目换掉); 跳级由 ⑤ 挡
#       (身上必须有前一级 —— 替换发生前校验, 所以链条照常成立)
#   【不同系】才要求有空槽: 已有条目 < 2(fit_slot_free)。
#   ★ 老物品(旧规则敲的, 最多 4 条)照样兼容: 逐条记 4 个槽; 不同系装不进就报满,
#     可以先用无色石消掉再敲。
data remove storage zx:work seen
scoreboard players set #up_serp zx.meta 0
# ★ #up_full 由这里归零(不是 helper 里) —— helper 只在"还有没有空槽"那一步被调,
#   同系(走替换、不查槽)时压根不跑; 归零放调用方才能保证"没查过 = 0"而不是留旧值。
scoreboard players set #up_full zx.meta 0
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[0] run data modify storage zx:work fs.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[0]
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[0] run function sweetdream:upgrade/api/ser_mark with storage zx:work fs
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[1] run data modify storage zx:work fs.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[1]
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[1] run function sweetdream:upgrade/api/ser_mark with storage zx:work fs
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[2] run data modify storage zx:work fs.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[2]
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[2] run function sweetdream:upgrade/api/ser_mark with storage zx:work fs
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[3] run data modify storage zx:work fs.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[3]
execute if data entity @s equipment.offhand.components."minecraft:custom_data".up[3] run function sweetdream:upgrade/api/ser_mark with storage zx:work fs

# 新石头自己的系列 -> 在不在键集里
$data modify storage zx:work fs.ser set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/ser_check with storage zx:work fs

# 同系已在 + 新的是一级石头(req 空) -> 不能往回敲, 按"这个系列已经敲过"拒
$execute if data storage zx:config updef."$(id)"{req:""} if score #up_serp zx.meta matches 1 run data modify storage zx:out r.reason set value "serdup"
$execute if data storage zx:config updef."$(id)"{req:""} if score #up_serp zx.meta matches 1 run return 0

# 不同系 -> 要有空槽(已有条目 < 2)。★ 不能靠 helper 里的 `return` 中断本函数 ★
#   —— `return` 只结束**它自己那次调用**, 控制权会回到这里继续往下跑, 最后一句
#   照样把 r.ok 置成 1b,"满了"就被静默吞掉 = **不限次数都能敲**(2026-10-07 事故)。
#   正确姿势: helper 只写标记分 #up_full, 由本函数判 + return。
execute unless score #up_serp zx.meta matches 1 run function sweetdream:upgrade/api/fit_slot_free
execute if score #up_full zx.meta matches 1 run data modify storage zx:out r.reason set value "full"
execute if score #up_full zx.meta matches 1 run return 0

# ④ 不重复
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{up:["$(id)"]}] run data modify storage zx:out r.reason set value "dup"
$execute if items entity @s weapon.offhand *[minecraft:custom_data~{up:["$(id)"]}] run return 0

# ⑤ 前置升级(α -> β -> Ω): 定义表里的 req 不是空就必须已经在身上
$data modify storage zx:work up.req set from storage zx:config updef."$(id)".req
function sweetdream:upgrade/api/fit_req with storage zx:work up
execute if score #up_reqbad zx.meta matches 1 run data modify storage zx:out r.reason set value "req"
execute if score #up_reqbad zx.meta matches 1 run return 0

data modify storage zx:out r.ok set value 1b

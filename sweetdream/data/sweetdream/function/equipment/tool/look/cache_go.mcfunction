# ============================================================
# sweetdream:equipment/tool/look/cache_go —— 缓存落库(宏: {uuid})
# ------------------------------------------------------------
# 【谁调用它】equipment/tool/look/cache(取好 uuid 之后) —— 执行者 = 玩家本人
# 【写哪】zx:look cache."<uuid>" = { eq:{<装备id>:1b,…}, skill:"sweetdream:<id>" }
#   两个键**都"先整格删、再按需写"**: 没有就整个键真的不存在
#   (读侧一律用 `if data` 判空 —— 残留上一秒的旧值会让人以为"还穿着/还拿着")。
# 【为什么整格删一次就够】eq 与 skill 是同一次采样的两个字段, 一起失效一起重建。
# 【★ N07: 这一格必须是"每人一份" ★】见 cache 头注释 —— 全局共用会被后跑的人覆盖。
# 【★ 为什么有的行有 `$` 有的没有 ★】含 $(uuid) 的行必须带 `$`;
#   不带宏变量的行**不能**带(`$` + 无宏变量 = 整个函数作废, 守门规则 dollar)。
# ============================================================

# ① 装备在身名单: 复用 equip_scan(它把 <id> 写进 zx:work eq.<id>), 完了整体搬进缓存
data remove storage zx:work eq
function sweetdream:debug/equip_scan {p:"SelectedItem"}
function sweetdream:debug/equip_scan {p:"equipment.offhand"}
function sweetdream:debug/equip_scan {p:"equipment.head"}
function sweetdream:debug/equip_scan {p:"equipment.chest"}
function sweetdream:debug/equip_scan {p:"equipment.legs"}
function sweetdream:debug/equip_scan {p:"equipment.feet"}

# ② 先把自己那一格清空, 再把"这一秒真实存在的键"写回去
$data remove storage zx:look cache."$(uuid)"
$execute if data storage zx:work eq run data modify storage zx:look cache."$(uuid)".eq set from storage zx:work eq

# ③ 手持武器的 skill 字段(观测镜冷却显示的"哪把武器")
#    ★ skill 是**字符串**(skill:"sweetdream:<id>", 见 _gen_batch5) —— 物品谓词
#    `custom_data~{skill:{}}` 测不了字符串键, 所以这里保留原来的
#    `if data entity` 判定(每秒一次, 只对面板玩家, 开销可忽略)。
$execute if data entity @s SelectedItem.components."minecraft:custom_data".skill run data modify storage zx:look cache."$(uuid)".skill set from entity @s SelectedItem.components."minecraft:custom_data".skill

# ④ 面板"当前生命"(原来 render_go 每刻 data get entity @s Health —— 又是一次全量
#    序列化)。每秒读一次缓存进 zx.hp_show, render_go 每刻只读计分板。
#    ★ zx.hp_c(criterion)只给"活着/死了"门用(账本自愈), 显示值不用它 ——
#      criterion 的刻度(×2 与否)没有先例背书, 别拿来做显示。
#    ★ 计分板天然是"每人一份", 这一项不需要 uuid 分片。
scoreboard players set @s zx.hp_show 0
execute store result score @s zx.hp_show run data get entity @s Health

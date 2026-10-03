# ============================================================
# sweetdream:debug/worn —— 身上 6 个槽位各穿了什么
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/worn   或   /trigger zx.dbg_worn
# 【为什么要它】换装之后"到底认没认出来"是这套装备系统最常见的问题:
#   认不到的装备 = 被动一个都不生效, 而游戏里**不会有任何提示**。
#   这里直接把每个槽位的 custom_data.zx[0] 读出来, 再翻成中文名 ——
#   显示英文 id 或 "不在表里" 就说明"认装备"这一步的匹配串写错了。
# 【它是只读的】不改任何数据。
#
# 【★ 2026-10-03 修: 槽位路径 ★】
#   原来用的读法(玩家 Inventory 的 100..103 = 盔甲, -106 = 副手)**在 1.21.5 已经不成立**。
#   1.21.5 把玩家穿戴的东西挪进了玩家 NBT 里一个独立的 equipment 复合标签:
#       equipment.head / chest / legs / feet / offhand / mainhand
#   实测: 玩家明明穿着静脉泵(chest)、iridescent(head)、mirage(legs)、dusk_dawn(feet),
#   而 Inventory 里 slots 只有 0..32(全是背包格子), 一个 100+ 的都没有。
#   → 所以下面盔甲/副手改读 equipment.*。
#   主手仍然是 Inventory 里被选中的那一格, `SelectedItem` 这个路径照旧好用(实测有效)。
#   注意: 空的装备位在 equipment 里**整键不存在**(不是空复合), 所以读出来自然就是空的。
# ============================================================

tellraw @s [{"text":"========== 身上穿了什么 ==========","color":"gold"}]

#       槽位名        读取路径
function sweetdream:debug/worn_slot {l:"主手  ",p:"SelectedItem"}
function sweetdream:debug/worn_slot {l:"副手  ",p:"equipment.offhand"}
function sweetdream:debug/worn_slot {l:"头盔  ",p:"equipment.head"}
function sweetdream:debug/worn_slot {l:"胸甲  ",p:"equipment.chest"}
function sweetdream:debug/worn_slot {l:"护腿  ",p:"equipment.legs"}
function sweetdream:debug/worn_slot {l:"靴子  ",p:"equipment.feet"}

tellraw @s [{"text":"(显示英文 id = 那件装备不在 zx:reg names 表里; 显示 — = 那个槽位是空的)","color":"dark_gray","italic":true}]
tellraw @s [{"text":"看各装备给了多少加成 -> ","color":"dark_gray","italic":true},{"text":"/trigger zx.dbg_stats","color":"aqua","italic":true}]

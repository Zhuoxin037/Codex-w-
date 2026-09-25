# ------------------------------------------------------------
# internal/debug/hud_entry —— 画出 ActionBar 调试信息
# 【宏参数】索引条目 {uuid,u0..u3,slot}
# 【显示内容】魔力 当前/上限, 术阵 数量/上限, 槽位号, UUID
# 【实现要点】/title @s actionbar 的 JSON 里用 {"score":{...}} 直接引用计分板,
#   所以不需要拼接字符串; 计分板是整数, 魔力这里按 1 倍缩放(四舍五入到整数),
#   想看精确小数请用 /function manacore:debug/dump。
# 【为什么把 UUID 也显示出来】多人排查问题时, 直接对照 UUID 与存储键,
#   能立刻确认"数据是不是写在正确的人身上"。
# ------------------------------------------------------------
$execute store result score #hp_cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana
$execute store result score #hp_max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana
$execute store result score #hp_limit manacore.math run data get storage manacore:players "$(uuid)".stats.formation_limit
execute store result score #hp_slot manacore.math run data get storage manacore:work entry.slot
function manacore:internal/formation/count_driver with storage manacore:work entry
$title @s actionbar [{"text":"[ManaCore] ","color":"aqua"},{"text":"魔力 ","color":"gray"},{"score":{"name":"#hp_cur","objective":"manacore.math"}},{"text":"/"},{"score":{"name":"#hp_max","objective":"manacore.math"}},{"text":"  术阵 ","color":"gray"},{"score":{"name":"#count","objective":"manacore.math"}},{"text":"/"},{"score":{"name":"#hp_limit","objective":"manacore.math"}},{"text":"  槽位 ","color":"dark_gray"},{"score":{"name":"#hp_slot","objective":"manacore.math"}},{"text":"  UUID ","color":"dark_gray"},{"text":"$(uuid)","color":"gray"}]

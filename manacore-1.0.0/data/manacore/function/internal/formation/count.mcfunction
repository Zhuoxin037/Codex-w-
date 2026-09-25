# ------------------------------------------------------------
# internal/formation/count —— 统计该玩家的术阵数量
# 【宏参数】manacore:work.a {uuid}
# 【出参】out.count(已用槽位数) / out.limit(该玩家的上限)
# 【实现】用固定 8 槽的展开式扫描统计(见 count_driver)。
# 【为什么不用 data get 的"列表长度"】列表长度恒为 8(空槽也占位),
#   那不是"术阵数量"。
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0}
function manacore:internal/formation/count_driver with storage manacore:work entry
execute store result storage manacore:out r.count int 1 run scoreboard players get #count manacore.math
$execute store result score #limit manacore.math run data get storage manacore:players "$(uuid)".stats.formation_limit
execute store result storage manacore:out r.limit int 1 run scoreboard players get #limit manacore.math

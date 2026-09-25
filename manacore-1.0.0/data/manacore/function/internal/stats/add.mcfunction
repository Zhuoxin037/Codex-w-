# ------------------------------------------------------------
# internal/stats/add —— 属性加法(仅数值)
# 【宏参数】manacore:work.a {uuid,key,value}
# 【第 1 行】如果 stats 里没有这个 key, 就先补 0.0, 防止下一步 data get 报错。
# 【第 2 行】两个条件都成立才做定点加法(见 add_calc)。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".stats unless data storage manacore:players "$(uuid)".stats."$(key)" run data modify storage manacore:players "$(uuid)".stats."$(key)" set value 0.0
$execute if data storage manacore:work a.value if data storage manacore:players "$(uuid)".stats."$(key)" run function manacore:internal/stats/add_calc with storage manacore:work a

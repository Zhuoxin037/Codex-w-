# ------------------------------------------------------------
# internal/debug/hud —— 刷新调试 HUD 的入口
# 【宏参数】manacore:work.a {i}
# 【做法】清空复用节点 -> 把索引条目搬进 work.entry -> 交给 hud_entry。
# 【为什么用 work.entry 而不是 work.a】hud_entry 内部还要调用 formation 的
#   count_driver, 那里会把 work.entry.i 当循环下标使用, 用独立节点避免互相干扰。
# ------------------------------------------------------------
execute if data storage manacore:work entry run data remove storage manacore:work entry
$execute if data storage manacore:index "$(i)" run data modify storage manacore:work entry set from storage manacore:index "$(i)"
execute if data storage manacore:work entry run function manacore:internal/debug/hud_entry with storage manacore:work entry

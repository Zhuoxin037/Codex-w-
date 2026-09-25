# ------------------------------------------------------------
# internal/debug/flag_on —— 开启调试标记
# 【宏参数】manacore:work.a {i}
# 【流程】用槽位号查索引, 确认注册完成后再写 players."uuid".debug = 1b。
# 【为什么还要写数据】计分板/tag 在重载后会丢, 数据不会 —— 两处都记,
#   调试状态才能跨 reload 保持。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(i)" run function manacore:internal/debug/flag_on_entry with storage manacore:index "$(i)"
$execute unless data storage manacore:index "$(i)" run tellraw @s [{"text":"[ManaCore] 尚未注册完成, 请等待 1 秒","color":"red"}]

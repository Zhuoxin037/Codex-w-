# ------------------------------------------------------------
# internal/debug/flag_off —— 关闭调试标记
# 【宏参数】manacore:work.a {i}
# 【注意】即使玩家还没注册(索引里查不到), 也只是没有反馈, 不会报错。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(i)" run function manacore:internal/debug/flag_off_entry with storage manacore:index "$(i)"

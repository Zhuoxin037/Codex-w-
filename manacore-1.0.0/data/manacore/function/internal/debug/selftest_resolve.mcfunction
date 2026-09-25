# ------------------------------------------------------------
# internal/debug/selftest_resolve —— 自检入口的身份解析
# 【宏参数】manacore:work.a {i}
# 【逻辑】能查到索引 -> 跑自检; 查不到 -> 提示等待注册完成。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(i)" run function manacore:internal/debug/selftest_run with storage manacore:index "$(i)"
$execute unless data storage manacore:index "$(i)" run tellraw @s [{"text":"[自检] 尚未注册, 请等待 1 秒后重试","color":"red"}]

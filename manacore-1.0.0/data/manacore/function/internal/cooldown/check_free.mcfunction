# ------------------------------------------------------------
# internal/cooldown/check_free —— 冷却已结束
# 【做什么】删掉这条已经没用的冷却记录, 保持数据干净。
# 【注意】这里不需要把 out.ready 改回 1b —— check 开头已经默认置 1b,
#         只有 busy 分支会把它改成 0b。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)" run data remove storage manacore:players "$(uuid)".cooldowns."$(skill)"

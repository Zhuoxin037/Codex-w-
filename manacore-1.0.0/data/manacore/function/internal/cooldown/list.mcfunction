# ------------------------------------------------------------
# internal/cooldown/list —— 列出该玩家全部冷却记录
# 【宏参数】manacore:work.a {uuid}
# 【出参】out.cooldowns(完整副本, 含 end/total/start)
# 【用途】调试面板 / 存档导出。
# ------------------------------------------------------------
data modify storage manacore:out r.cooldowns set value {}
$execute if data storage manacore:players "$(uuid)".cooldowns run data modify storage manacore:out r.cooldowns set from storage manacore:players "$(uuid)".cooldowns

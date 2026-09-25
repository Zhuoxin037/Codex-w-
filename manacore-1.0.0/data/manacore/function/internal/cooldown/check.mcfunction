# ============================================================
# internal/cooldown/check —— 查询某技能是否冷却完毕
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,skill}
# 【出参】out.ready     = 1b 可以放 / 0b 冷却中
#         out.remaining = 剩余 tick(就绪时为 0)
# 【关键点】冷却数据是按 技能 id 为键存在"该玩家"记录里的, 所以
#   - 不同技能互不影响(多个技能同时冷却)
#   - 不同玩家的冷却完全隔离(不同玩家独立冷却)
# 这两条需求就是靠这个数据结构天然满足的。
# ------------------------------------------------------------
# 出参: manacore:out.ready / manacore:out.remaining
data modify storage manacore:out r.ready set value 1b
data modify storage manacore:out r.remaining set value 0
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".end run function manacore:internal/cooldown/check_has with storage manacore:work a

# ============================================================
# api/cooldown/check —— 查询技能是否冷却完毕
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"fireball"}
#          function manacore:api/cooldown/check
# 【出参】out.ready     = 1b 可以放 / 0b 冷却中
#         out.remaining = 剩余 tick
# 【只读】不修改任何数据(除了顺手清掉已过期的记录)。
# 【多人/多技能】冷却存在每个玩家自己的记录里, 按 skill 分键,
#   所以天然满足"多个技能同时冷却 + 每个玩家独立"。
# ============================================================
# 出参: manacore:out.ready(1b/0b), manacore:out.remaining(tick)
data modify storage manacore:work a set value {uuid:"",skill:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.skill run function manacore:internal/cooldown/check with storage manacore:work a

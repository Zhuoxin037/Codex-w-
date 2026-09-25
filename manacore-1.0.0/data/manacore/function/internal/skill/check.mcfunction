# ============================================================
# internal/skill/check —— 技能可用性查询(不产生任何副作用)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,skill,mana}
# 【出参】out.ready(冷却是否就绪) / out.success(是否真的能放)
#         out.remaining(剩余冷却) / out.reason
# 【用途】在真正施法前做判断: 例如按下技能键时先查, 就绪才走 cast,
#   可以避免"扣了蓝才发现冷却没好"之类的体验问题(虽然 cast 本身也安全)。
# 【和 cast 的区别】这里绝不修改任何数据(不扣蓝、不记冷却)。
# ============================================================
function manacore:internal/cooldown/check with storage manacore:work a
execute if data storage manacore:out r{ready:1b} run function manacore:internal/skill/check_mana with storage manacore:work a
execute if data storage manacore:out r{ready:0b} run function manacore:internal/skill/check_block with storage manacore:work a

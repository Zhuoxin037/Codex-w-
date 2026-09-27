# ============================================================
# api/skill/check —— 技能能否释放(只读)
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"mypack:fireball", mana:20.0}
#          function manacore:api/skill/check
# 【出参】out.success(1b 可释放) / out.ready(冷却) / out.remaining / out.reason
# 【用途】按下技能键时先查, 决定是"施放/灰显/提示蓝不够"。
# 【完全不改数据】不扣蓝、不进冷却, 随便高频调用。
# ============================================================
data modify storage manacore:work a set value {uuid:"",mana:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.success set value 1b
data modify storage manacore:out r.ready set value 1b
data modify storage manacore:out r.reason set value "ok"
execute if data storage manacore:work a.uuid if data storage manacore:work a.skill run function manacore:internal/skill/check with storage manacore:work a

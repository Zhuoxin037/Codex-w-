# ============================================================
# api/stats/get —— 读取某个玩家的一项属性
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<玩家UUID>", key:"max_mana"}
#   function manacore:api/stats/get
#   读取结果: /data get storage manacore:out r.value
# 【入参】uuid = 玩家 UUID 文本; key = 属性名
# 【出参】out.value / out.key / out.uuid
# 【可用 key】current_mana, max_mana, base_attack, max_health, custom_damage,
#   skill_multiplier, independent_multiplier, cooldown, mana_regen,
#   mana_regen_multiplier, cooldown_reduction, formation_limit
#   —— 也可以读你自己用 stats/set 加进去的任意自定义属性。
# 【怎么拿到 uuid】通常从前置包的事件上下文 manacore:ctx.uuid 取。
# ============================================================
# 出参: manacore:out.value
data modify storage manacore:work a set value {uuid:"",key:"current_mana"}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:internal/stats/get with storage manacore:work a

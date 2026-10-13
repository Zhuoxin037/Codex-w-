# ============================================================
# sweetdream:equipment/sword/crescent/pass1 —— 1 个技能在冷却
# ------------------------------------------------------------
# 【原文】"只有 1 个技能正在冷却：普通攻击额外造成相当于自身基础攻击力 ×2 的伤害。"
# 【执行者】玩家   【目标】被击中的那一只(zx.victim)
# 【伤害口径】基础攻击力 ×2 -> attack_mul 通道。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.victim]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.4 0.5 0.4 0.04 10 normal

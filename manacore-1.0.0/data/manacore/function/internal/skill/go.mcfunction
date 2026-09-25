# ============================================================
# internal/skill/go —— 技能真正生效
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,skill,cooldown,cooldown_seconds,reduce,
#          base_attack,skill_multiplier,independent_multiplier,
#          custom_damage,health_ratio,target,type}
# 【顺序】
#   1) cooldown/start  : 立刻进入冷却("释放成功后才开始冷却")
#   2) damage/calc     : 算伤害 -> out.damage
#   3) 若给了 target   : 把 out.damage 搬进参数节点, 再 damage/apply
#   4) out.success=1b  / out.reason="ok"
#   5) 抛 #manacore:event/skill_cast(带 uuid 与 skill)
# 【技能的实际效果放哪】前置包只负责"算伤害 + 打伤害 + 记冷却"。
#   位移/粒子/音效/召唤物等表现请写在 #manacore:event/skill_cast 里,
#   这样同一个计算核心可以服务无限多种技能。
# ============================================================
function manacore:internal/cooldown/start with storage manacore:work a
function manacore:internal/damage/calc with storage manacore:work a
execute if data storage manacore:work a.target run data modify storage manacore:work a.damage set from storage manacore:out r.damage
execute if data storage manacore:work a.target run function manacore:internal/damage/apply with storage manacore:work a
data modify storage manacore:out r.success set value 1b
data modify storage manacore:out r.reason set value "ok"
$data modify storage manacore:ctx skill set value "$(skill)"
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "cast"
function #manacore:event/skill_cast

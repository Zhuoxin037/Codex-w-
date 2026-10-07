# ============================================================
# sweetdream:equipment/bow/arc/hook_arrow —— 附魔回调: 记下"造成伤害的那支箭"
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:arc(「电弧」)的 post_attack, affected = damaging_entity
#   —— "直接造成这次伤害的实体"。玩家射箭时它就是那支箭; 近战敲人时是玩家本人。
# 【执行者】damaging_entity(通常就是那支箭)
# 【★ 近战门控 ★】damaging_entity 不是箭时这里不打标签, 于是 hook_victim 开头
#   "必须有 zx.arc_arr 才继续"就不成立 -> 近战直接收工, 不会误触发。
#   (同类坑 2026-10-05: 弩不做这个门控 = 近战敲人也触发技能、不耗蓝、用上一发快照的层数。)
# 【顺序】它排在效果表的第一条, 所以 hook_victim 跑到时标签已经打好。
# ============================================================

tag @e[tag=zx.arc_arr] remove zx.arc_arr
execute if entity @s[type=#sweetdream:cc_arrow] run tag @s add zx.arc_arr

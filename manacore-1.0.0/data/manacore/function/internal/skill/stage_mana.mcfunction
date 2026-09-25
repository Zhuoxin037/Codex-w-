# ------------------------------------------------------------
# internal/skill/stage_mana —— 魔力扣除阶段
# 【宏参数】manacore:work.a {uuid,skill,consume,mana}
# 【流程】consume=1b 才真的扣; 扣完看 out.success:
#         0b -> fail_mana(中断, 且魔力没被扣掉)
#         1b -> go(继续执行技能)
# 【consume 开关】给"某些技能不耗蓝"或"只想算伤害不想扣蓝"的场景用。
# ------------------------------------------------------------
execute if data storage manacore:work a{consume:1b} run function manacore:internal/mana/consume with storage manacore:work a
execute if data storage manacore:out r{success:0b} run function manacore:internal/skill/fail_mana with storage manacore:work a
execute if data storage manacore:out r{success:1b} run function manacore:internal/skill/go with storage manacore:work a

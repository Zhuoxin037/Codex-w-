# ------------------------------------------------------------
# internal/skill/stage_mana —— 魔力扣除阶段
# 【宏参数】manacore:work.a {uuid,skill,consume,mana}
# 【流程】consume=1b 才真的扣; 扣完看 out.success:
#         0b -> fail_mana(中断, 且魔力没被扣掉)
#         1b -> go(继续执行技能)
# 【consume 开关】给"某些技能不耗蓝"或"只想算伤害不想扣蓝"的场景用。
# ------------------------------------------------------------
# 【★★ 参数口径修正(2026-10-10, 修 F06)★★】
#   internal/mana/consume 的入参口径是 **a.value**(见该函数与 api/mana/consume),
#   而 api/skill/cast 的技能契约字段叫 **mana** —— 两边对不上:
#     consume 里 `data get storage manacore:work a.value 1000` 读不到 ⇒ #need 恒 = 0
#     ⇒ "永远够蓝" 而且 **真实扣除 0 点**。
#   症状: 走 api/skill/cast 的技能一点也不耗蓝; 而 api/skill/check(只读) 用的是
#     a.mana, 所以 UI 还会老老实实报"魔力不足" —— 查得到、扣不着, 最迷惑的那种。
#   这里做一次**显式映射**: 扣费期间把 mana 放进 value, 扣完立刻移除,
#   叫"恢复施法上下文"(免得 a.value 漏给后面的 damage/calc 当垃圾字段)。
execute if data storage manacore:work a{consume:1b} run data modify storage manacore:work a.value set from storage manacore:work a.mana
execute if data storage manacore:work a{consume:1b} run function manacore:internal/mana/consume with storage manacore:work a
execute if data storage manacore:work a{consume:1b} run data remove storage manacore:work a.value

# 【consume:0b 的补丁(2026-10-08)】不扣蓝时必须**显式**把 success 置 1b。
#   否则它会停在 api/skill/cast 预置的 0b 上, 被下一行误判成"魔力不足" -> 走 fail_mana,
#   go 永不执行 —— 等于"所有 consume:0b 的技能都放不出来"
#   (而 api/skill/cast 的字段速查里明明写着 consume 默认 1b、可设 0b)。
execute unless data storage manacore:work a{consume:1b} run data modify storage manacore:out r.success set value 1b
execute unless data storage manacore:work a{consume:1b} run data modify storage manacore:out r.reason set value "ok"

execute if data storage manacore:out r{success:0b} run function manacore:internal/skill/fail_mana with storage manacore:work a
execute if data storage manacore:out r{success:1b} run function manacore:internal/skill/go with storage manacore:work a

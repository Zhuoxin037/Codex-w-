# ============================================================
# sweetdream:equipment/armor/styx_walk/scan_mul —— 面板: 暗海内 +30% 折进最大魔力倍率
# ------------------------------------------------------------
# @panel: smul_mm
# 【执行者】玩家本人(@s)
# 【出参】仅当"穿着漫步冥河 且 自身 3 格内有暗海"时, 往**加算池** zx:work add 的
#   mm 通道写 30; 由 lib/skill_mul/padd_apply 统一折进 pl.smul_mm(面板上
#   "最大魔力值技能倍率 ×"那一行)。
# 【★ 结算不在这里 ★】真正的加伤是 hook_calc 往同一个加算池写 30, 由
#   lib/dmg_add_apply 统一乘进 manacore:out r.damage。面板第一原则是
#   "显示的必须是真实生效的" —— 不折进来的话, 玩家站在暗海里看 stats 还是 ×1,
#   会以为没生效(2026-10-06 用户反馈: "在暗海内看自己的 stats 没看见最大魔力倍率提升")。
#   套路和共振 resonance/scan_mul 完全一样。
# 【为什么只写 mm】文案限定"使用关于最大魔力值的技能时技能伤害 +30%"
#   —— 正好就是 max_mana_mul 这条通道(攻击力类 / 当前魔力类技能吃不到)。
# 【判据必须和 hook_calc 逐字一致】戴着 + 3 格内有暗海, 缺一条就收工,
#   面板保持原值 —— 两边判据一旦走散, 面板就又变成"说假话"了。
# 【★ 不再自己乘 smul_mm ★】"先合并再乘一次"才是加算: 和共振叠起来是
#   ×(1 + 0.1n + 0.3), 不是 ×1.1n ×1.3(2026-10-06 改)。
# ============================================================

# ① 没戴漫步冥河 -> 不参与
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["styx_walk"]}] run return 0

# ② 自身 3 格内没有暗海 -> 不参与(和 hook_calc 同款判据)
execute at @s unless entity @e[tag=zx.sea,distance=..3,limit=1] run return 0

# ③ 往加算池的 mm 通道贡献 +30%
data modify storage zx:work put.pct set value 30
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put

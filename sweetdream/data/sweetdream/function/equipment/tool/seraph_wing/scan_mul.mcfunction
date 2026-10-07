# ============================================================
# sweetdream:equipment/tool/seraph_wing/scan_mul —— 面板: 炽天使之翼 +50% 折进攻击力通道
# ------------------------------------------------------------
# @panel: smul_atk
# 【执行者】玩家本人(@s)
# 【出参】仅当副手拿着「炽天使之翼」时, 往**加算池** zx:work add 的 atk 通道写 50;
#   由 lib/skill_mul/padd_apply 统一折进 pl.smul_atk(面板"基础攻击力倍率 ×"那一行)。
# 【★ 结算不在这里 ★】hook_calc 往同一个池子写 50, 由 lib/dmg_add_apply 判断
#   "本次技能到底走没走攻击力通道"再统一乘。面板第一原则是"显示的必须是真实
#   生效的" —— 不折进来的话, 玩家拿着副手看 stats 还是 ×1(2026-10-06 漫步冥河
#   就是这么被反馈的)。套路同 resonance/scan_mul。
# 【为什么只写 atk】文案限定"有关基础攻击力的技能" —— 正好就是 attack_mul
#   这条通道(最大魔力类 / 当前魔力类技能吃不到)。
# 【判据必须和 hook_calc 逐字一致】(副手拿着) —— 缺一条面板就变成说假话。
# 【★ 不再自己乘 smul_atk ★】加算是"先合并再乘一次"(2026-10-06 改)。
# ============================================================

# ① 副手没拿「炽天使之翼」-> 不参与
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["seraph_wing"]}] run return 0

# ② 往加算池的 atk 通道贡献 +50%
data modify storage zx:work put.pct set value 50
data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put

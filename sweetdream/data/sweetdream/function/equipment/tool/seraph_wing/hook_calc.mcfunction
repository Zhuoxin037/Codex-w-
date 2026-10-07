# ============================================================
# sweetdream:equipment/tool/seraph_wing/hook_calc —— 炽天使之翼: 攻击力类技能 +50%
# ------------------------------------------------------------
# @calc: add     ← 这是"加算"型 hook: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 前置包在每次 api/damage/calc 算完之后抛。
#   (与共振 resonance/hook_calc、漫步冥河 styx_walk/hook_calc 同一条路。)
# 【文案】持于副手时，自身**有关基础攻击力的**技能伤害提升 50%。
# 【★ "按通道区分"在这套架构里怎么落地 ★】
#   文案限定"关于基础攻击力的技能" ⇒ 只往**加算池的 atk 通道**写 50。
#   判"本次技能走没走攻击力通道"这一步**不在本文件** —— 它是 lib/dmg_add_apply
#   的活(读快照 zx:work ch.attack_mul): 走了才把 atk 池子加上去。
#   ⇒ 好处: 加算/独立乘区的区别、通道判断、并发叠加 全在一个地方, 各装备 hook
#     只管"我贡献多少", 不会再出现"每件装备各乘一次"的老毛病。
# 【为什么读快照 zx:work ch 而不是 manacore:work a】那是 apply 的事, 但道理要记住:
#   同一个 damage_calc 事件里 resonance/hook_calc 会调 api/formation/count,
#   而那个接口第一行就把 manacore:work a **整份重置**成 {uuid:""} ⇒ 谁在这之后
#   直接读 a, 三条通道都是 0(本件会一次都不生效且不报错)。快照由事件第一条
#   lib/dmg_ch 拍下, 顺序由 check 规则 dmgch 锁死。
# 【加算口径】文案没写"独立乘区" ⇒ 加算(写进池子, 与共振/漫步相加, 不是相乘)。
# ============================================================

# ⓪ 不是玩家(法球 / 箭 / 命令方块在算伤害) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 副手没拿「炽天使之翼」-> 不参与
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["seraph_wing"]}] run return 0

# ② 写进加算池: atk 通道 +50%
data modify storage zx:work put.pct set value 50
data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put

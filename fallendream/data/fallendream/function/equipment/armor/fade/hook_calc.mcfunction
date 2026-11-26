# ============================================================
# fallendream:equipment/armor/fade/hook_calc —— 超限·息影: 被武装技能伤害 +10%
# ------------------------------------------------------------
# @calc: add     ← 加算型 hook: 只往加算池写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 注册在 lib/dmg_add_apply **之前**
# 【执行者】施法者本人(玩家) —— calc 一路传下来 @s 就是放技能的人
# 【触发】go/cd_half 兑现"冷却减半"时给玩家打 zx.fd_next —— 表示"这一个被减冷却的技能"
#   下一次走 calc 时吃到 +10% 伤害且命中目标附随机标签。文案:
#   "释放该装备提供的减冷却后的技能时该技能伤害 +10% 并使受到伤害的生物
#     额外附加五大标签的随机一种。"
# 【★ 一次性 ★】calc 每次施法只算一遍 → 这里正好是"一次施法"的消费点:
#   ① 先清 zx:work fd.tag（防上一发的信号残留到没有 fd_next 的下一发）
#   ② 有 fd_next 才重新打 fd.tag + 写加算池 +10
#   ③ 消费 zx.fd_next tag —— 下一发不再吃
# 【fd.tag 怎么传到 one】写在 zx:work 的独立键, one 在 deal 之后读它给每只目标附标签。
#   ★ 不写 manacore:work a —— 那会在 calc 事件末尾被 ctx 整份还原掉(见 damage/calc ⑥)。
# 【★ 不挑通道 ★】文案"技能伤害 +10%"不挑口径 ⇒ dmg_add_put_any 三条通道各写一份
#   (与 mottle_vein 同款, D01 口径 B: 分量级, 三条各乘各的段 = 整段 +10%)。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0

# ① 先清信号（范围伤害里前一目标收尾钩子可能触发新 calc, 不能让它带着上一发标记）
data remove storage zx:work fd.tag

# ② 没穿超限息影 / 没有 fd_next 武装 -> 收工
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"],ol:"fade"}] run return 0
execute unless entity @s[tag=zx.fd_next] run return 0

# ③ 打信号 + 写加算池 +10（三通道）
data modify storage zx:work fd.tag set value 1b
scoreboard players set #pct zx.meta 10
execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
function fallendream:lib/dmg_add_put_any

# ④ 消费武装
tag @s remove zx.fd_next

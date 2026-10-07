# ============================================================
# sweetdream:equipment/bow/arc/hook_victim —— 「电弧」命中回调(实装)
# ------------------------------------------------------------
# 【谁调用】enchantment/arc.json 的 post_attack -> affected:"victim"
#   即"这把弩射出的箭打中生物"时由原版回调, 命中判定交给原版。
# 【执行者】@s = 被打中的那只生物(玩家除外, 见门控)
# 【★ 近战门控 ★】必须先有 hook_arrow 打上的 zx.arc_arr(那支箭), 否则说明是
#   拿弩近战敲人 -> 直接收工。这条门控不能删。
# 【技能原文(lore 逐字)】
#   「每次射击都会对被攻击的生物附加「电刺」效果。若附有「电刺」的生物 6 格内有
#    另一个附有「电刺」的生物，则立即在他们之间产生一道 1 格宽的电线并对沿途的
#    生物及他们自身造成一次相当于自身基础攻击力 ×2+ 当前魔力值 ×0.03 的伤害，
#    之后移除「电刺」。」
# 【四要素】
#   触发   = 弩射出的箭命中生物(每次命中一次)
#   目标范围= ①本只(附加「电刺」) ②6 格内另一只带电刺的生物 ③二者之间那 1 格宽
#             电线沿途的生物 + 那两只自身
#   次数   = 每次命中一次(命中即刻判定)
#   时长   = 「电刺」不设时限: 只在"配对放电"时移除(文案明说"之后移除「电刺」",
#             未给到期时间 —— 不擅自编一个时长)
# 【「电刺」存哪】原生标签 zx.status.dianci(只需"在不在", 不走 tag/mark 那套五状态图标)。
#   ★ 口径 2026-10-07: 文案没写「电刺」多久掉, 所以**不设时限** —— 它在配对放电时
#     被移除, 或者跟着生物一起死掉。常态特效交给 status/aura_dianci 每秒画。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.arc_arr)直接收工
execute unless entity @e[tag=zx.arc_arr,distance=0..,limit=1] run return 0

# ① 受害者必须是**生物**(排除玩家): 标出来, 玩家一律不收工
tag @e[tag=zx.arc_v,distance=0..] remove zx.arc_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.arc_v
execute unless entity @e[tag=zx.arc_v,distance=0..,limit=1] run return 0

# ② 给这一只附加「电刺」(命中瞬间抖一下电火花)
tag @s add zx.status.dianci
execute at @s run particle minecraft:electric_spark ~ ~1.0 ~ 0.3 0.4 0.3 0.05 8 normal

# ③ 扫 6 格内**另一个**带「电刺」的生物(排除自己 -> tag=!zx.arc_v)
tag @e[tag=zx.arc_partner,distance=0..] remove zx.arc_partner
execute at @s run tag @e[tag=zx.status.dianci,tag=!zx.arc_v,distance=0..6,limit=1,sort=nearest] add zx.arc_partner

# ④ 没配对上 -> 收工(「电刺」留着, 等下一箭再来找伙伴)
execute at @s unless entity @e[tag=zx.arc_partner,distance=0..,limit=1] run return 0

# ⑤ 配上了 -> 放电结算(电刺 / 电线 / 沿途伤害 / 移除电刺)
execute at @s run function sweetdream:equipment/bow/arc/discharge

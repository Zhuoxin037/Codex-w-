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
# 【★ 超限版走哪条路】本文件只负责"附加「电刺」+ 配对 + 分流":
#   基础版 -> discharge(即刻一次性结算);
#   超限版 -> ol_begin(起一个 3 秒的放电锚, 由 lib/second 每秒一跳: 8 格内重判配对、
#             3 格宽电线 ol_wire、沿途 + 两端 1 格内伤害、落雷, 3 秒后移除「电刺」)。
#   ⇒ 判定半径要跟着版本走: ③ 的 6 格是基础版口径, 超限版补扫到 8(见 ③ 的第二行)。
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
#    ★ 超限版配对半径是 **8**(原文"8 格内有另一个…"), 基础版是 6。
#      光靠这一条 6 格扫描, 6~8 格的配对**根本进不了 ⑤ 的超限分支**(连门都进不去),
#      所以基础半径扫不到、而射手这把是超限时, 再补扫 6~8 这一圈。
tag @e[tag=zx.arc_partner,distance=0..] remove zx.arc_partner
execute at @s run tag @e[tag=zx.status.dianci,tag=!zx.arc_v,distance=0..6,limit=1,sort=nearest] add zx.arc_partner
execute at @s unless entity @e[tag=zx.arc_partner,distance=0..,limit=1] if score @a[tag=zx.arc_pl,limit=1] zx.arc_ol matches 1.. run tag @e[tag=zx.status.dianci,tag=!zx.arc_v,distance=6..8,limit=1,sort=nearest] add zx.arc_partner

# ④ 没配对上 -> 收工(「电刺」留着, 等下一箭再来找伙伴)
execute at @s unless entity @e[tag=zx.arc_partner,distance=0..,limit=1] run return 0

# ⑤ 配上了 -> 分流: 超限版走"持续 3 秒"那套(ol_begin => 放电锚), 原版即刻结算
#    ★ 判据是**射手**身上的 zx.arc_ol 快照(shot 在离弦那刻拍的), 不是受害者;
#      射手靠 zx.arc_pl 标签找回(附魔回调排过序, 跑到这行时射手已标好)。
#      选择器落空(射手不在)时 `unless score` 成立 -> 走原版, 是安全的兜底。
execute at @s if score @a[tag=zx.arc_pl,limit=1] zx.arc_ol matches 1.. run function sweetdream:equipment/bow/arc/ol_begin
execute at @s unless score @a[tag=zx.arc_pl,limit=1] zx.arc_ol matches 1.. run function sweetdream:equipment/bow/arc/discharge

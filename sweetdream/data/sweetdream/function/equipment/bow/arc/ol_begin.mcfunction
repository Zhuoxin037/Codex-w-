# ============================================================
# sweetdream:equipment/bow/arc/ol_begin —— 超限·电弧: 配对成功, 起「持续放电」
# ------------------------------------------------------------
# 【谁调用它】arc/hook_victim 第 ⑤ 步(射手那把是超限版时)
# 【执行者/位置】受害者 @s(配对的一端), 调用方已 at @s
# 【技能原文(超限版, 逐字)】
#   "每次射击都会对被攻击的生物附加「电刺」效果。若附有「电刺」的生物 8 格内有
#    另一个附有「电刺」的生物，则每秒都会在他们之间产生一道 3 格宽的电线并对沿途
#    的生物及他们自身 1 格内的全部生物造成一次相当于自身基础攻击力 ×2+ 当前魔力值
#    ×0.03 的伤害并召唤闪电，持续 3 秒。之后移除「电刺」。"
# 【与原版的差别】
#   原版 = 配对即刻**一次性**结算(6 格内 / 1 格宽 / 只算两端与走廊);
#   超限 = 起一个 **3 秒的放电锚**(marker), 每秒跳一次: 8 格内重判配对、
#          3 格宽走廊、沿途 + **两端各自 1 格内**的全部生物、并且落雷。
# 【★ 伤害快照】"自身基础攻击力 ×2+ 当前魔力值 ×0.03" 的"自身" = 射手。
#   3 秒里拿不到射手, 所以起放电时就算好 d2 + 归属 u0..u3 存进锚点。
# 【★ 为什么"每秒重判配对"】原文的条件是"8 格内有另一个带电刺的生物" —— 逐秒成立
#   才放电; 不是"锁死这一对"。所以每一跳都重新找最近的另一个「电刺」。
# ============================================================

# ⓪ 这一对已经在放电窗口里了就别再起第二份(窗口计时 zx.arc_dt, 见 ol_sweep)
execute if score @s zx.arc_dt matches 1.. run return 0
execute if entity @e[tag=zx.arc_partner,scores={zx.arc_dt=1..},distance=0..,limit=1] run return 0

# ① 两端 UUID(锚点逐秒按它回查端点; 每次新配对覆盖旧值)
data modify storage zx:work aw set value {d2:0.0,u0:0,u1:0,u2:0,u3:0,a0:0,a1:0,a2:0,a3:0,b0:0,b1:0,b2:0,b3:0}
data modify storage zx:work aw.a0 set from entity @s UUID[0]
data modify storage zx:work aw.a1 set from entity @s UUID[1]
data modify storage zx:work aw.a2 set from entity @s UUID[2]
data modify storage zx:work aw.a3 set from entity @s UUID[3]
execute as @e[tag=zx.arc_partner,distance=0..,limit=1] run data modify storage zx:work aw.b0 set from entity @s UUID[0]
execute as @e[tag=zx.arc_partner,distance=0..,limit=1] run data modify storage zx:work aw.b1 set from entity @s UUID[1]
execute as @e[tag=zx.arc_partner,distance=0..,limit=1] run data modify storage zx:work aw.b2 set from entity @s UUID[2]
execute as @e[tag=zx.arc_partner,distance=0..,limit=1] run data modify storage zx:work aw.b3 set from entity @s UUID[3]

# ② 以射手身份把这一跳的伤害与归属算成快照
execute as @a[tag=zx.arc_pl,scores={zx.arc_ol=1..},limit=1] at @s run function sweetdream:equipment/bow/arc/ol_calc

# ③ 两端进入放电窗口(窗口期 3 秒, 由 ol_sweep 每秒 -1 —— 锚点万一丢了也能自愈)
scoreboard players set @s zx.arc_dt 3
tag @s add zx.arc_dis
execute as @e[tag=zx.arc_partner,distance=0..] run scoreboard players set @s zx.arc_dt 3
execute as @e[tag=zx.arc_partner,distance=0..] run tag @s add zx.arc_dis

# ④ 生成放电锚(带 d2 / 归属 / 两端 UUID)
function sweetdream:equipment/bow/arc/ol_spawn with storage zx:work aw

# ⑤ 表现: 起手一声闷雷 + 两端火花
playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.8 1.4
particle minecraft:electric_spark ~ ~1.0 ~ 0.6 0.8 0.6 0.06 12 normal

# ⑥ 摘掉本流程的临时标签(hook_victim 打的两只)
tag @s remove zx.arc_v
tag @e[tag=zx.arc_partner,distance=0..] remove zx.arc_partner

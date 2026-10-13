# ============================================================
# sweetdream:equipment/bow/arc/ol_fire —— 超限·电弧: 放电的一跳(宏)
# ------------------------------------------------------------
# 【谁调用它】ol_tick_go: if score <锚> zx.arc_wt matches 1.. as <A> at @s run
#             function .../ol_fire with storage zx:work aw
# 【执行者/位置】A 端(配对的一端, 非玩家生物); 调用方已 at @s
# 【宏参数(来自 zx:work aw)】b0..b3 = B 端 UUID 四个整数(逐秒回查 B 在不在);
#   伤害/归属不占宏参数 —— 直接从 zx:work aw.d2 / aw.u0..u3 拷(见 ol_calc)。
#   ★ aw 就是锚的 data.zx(ol_tick 原样抬过来), 所以那 12 个 UUID 整数在锚上
#     必须是**独立键** d2/u0..u3/a0..a3/b0..b3(见 ol_spawn 头部)。
# 【技能原文(超限版, 逐字)】
#   "若附有「电刺」的生物 8 格内有另一个附有「电刺」的生物，则每秒都会在他们之间
#    产生一道 3 格宽的电线并对沿途的生物及他们自身 1 格内的全部生物造成一次相当于
#    自身基础攻击力 ×2+ 当前魔力值 ×0.03 的伤害并召唤闪电，持续 3 秒。之后移除「电刺」。"
# 【每一跳的六件事】
#   ① 8 格内**重判**配对(原文条件是"8 格内有另一个", 是逐秒成立而不是锁死这一对)
#   ② 3 格宽电线(ol_wire 递归) + 两端落位
#   ③ 两端各自 1 格内的全部生物入列(含两端自身)
#   ④ 结算: 伤害快照 d2 + 归属 u0..u3(都是起放电那刻以射手身份算好的)
#   ⑤ 表现: 闷雷音效 + 火花
#   ⑥ 召唤闪电(**只在配对成立时**, 原文的"则…并召唤闪电"是条件句)
# 【★ 伤害为什么不用再切射手】ol_calc 已经把面板口径算成 d2、把归属算成 u0..u3
#   存进锚了 —— 这 3 秒里射手会走位/会死, 拿不到他, 只能用快照(同崩裂·裂缝)。
# 【★ 目标为什么要带 distance=0..】把 with_from 的选择器锁在**放电锚所在维度**
#   (裸 @e 会跨维度搜, 见 RULES 坑 55)。
# ============================================================

# ---- ① 8 格内重判配对(排除自己: 自己到锚的位置距离 ≈ 0) ----
tag @e[tag=zx.arc_partner,distance=0..] remove zx.arc_partner
execute at @s run tag @e[tag=zx.status.dianci,distance=0.1..8,limit=1,sort=nearest] add zx.arc_partner

# 没配到 -> 这一跳不放电(「电刺」留着, 下一跳再来找)
execute at @s unless entity @e[tag=zx.arc_partner,distance=0..,limit=1] run return 0

# ---- ② 3 格宽电线 ----
scoreboard players set #arc_st zx.meta 0
tag @e[tag=zx.arc_on,distance=0..] remove zx.arc_on
tag @s add zx.arc_on
execute as @e[tag=zx.arc_partner,distance=0..] run tag @s add zx.arc_on
execute at @s facing entity @e[tag=zx.arc_partner,distance=0..,limit=1] feet run function sweetdream:equipment/bow/arc/ol_wire

# ---- ③ 两端各自 1 格内的全部生物(原文"及他们自身 1 格内的全部生物") ----
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..1] add zx.arc_on
$execute at @e[nbt={UUID:[I;$(b0),$(b1),$(b2),$(b3)]}] run tag @e[type=!#sweetdream:no_damage,distance=..1] add zx.arc_on

# ---- ④ 结算(伤害快照 + 归属, 都从锚上拷) ----
data modify storage zx:work a set value {target:"@e[tag=zx.arc_on,distance=0..]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work a.damage set from storage zx:work aw.d2
data modify storage zx:work a.u0 set from storage zx:work aw.u0
data modify storage zx:work a.u1 set from storage zx:work aw.u1
data modify storage zx:work a.u2 set from storage zx:work aw.u2
data modify storage zx:work a.u3 set from storage zx:work aw.u3
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a

# ---- ⑤ 表现: 闷雷 + 火花 ----
playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.8 1.4
particle minecraft:electric_spark ~ ~1.0 ~ 0.6 0.8 0.6 0.06 12 normal

# ---- ⑥ 召唤闪电(带 zx.th_seen: 免被 tool/thunder/strike 当"新雷"接管连锁) ----
summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_seen"]}

# ---- ⑦ 清场(走廊标签; 下一跳开头还会再清一次, 这里只是不留脏) ----
tag @e[tag=zx.arc_on,distance=0..] remove zx.arc_on

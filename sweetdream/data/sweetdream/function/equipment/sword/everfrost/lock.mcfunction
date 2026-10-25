# ============================================================
# sweetdream:equipment/sword/everfrost/lock —— 冻住 8 个 + 记账(宏 {uuid})
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {uuid}   【执行者】施法者
# 【记在哪】施法者名下独立记录 zx:data ef."<uuid>"; 目标只用原版标签 zx.ef_<uuid> 认。
# 【冻结】走 lib/freeze(宏 {target,ticks}): TicksFrozen + 移动速度 -100%, 3 秒 = 60 tick。
#   ★ 调用它前先设好 zx:work fz —— 宏参数缺字段会让整条宏调用失败(静默)。
# ============================================================

# 清掉上一轮残留(连 zx.ef_fin 一起清 —— 那是"准备结算最后一下"的临时标签,
#   万一上一轮有目标跑到别的维度没被清掉, 这一轮它会被 `tag=!zx.ef_fin` 永久排除)
tag @e[tag=zx.ef_fin] remove zx.ef_fin
$tag @e[tag=zx.ef_$(uuid)] remove zx.ef_$(uuid)

# 冻: 5 格内 —— 基础版就近取 8 个 / 超限版**全部**(文案: 冰冻自身 5 格范围内的全部生物)
#   ★ 两条都写、用 ol 分流, 不在一条选择器里做手脚 —— 以后改数值只看这两行。
$execute if data storage zx:work a{ol:0b} run tag @e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=8] add zx.ef_$(uuid)
$execute if data storage zx:work a{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=0.1..5] add zx.ef_$(uuid)

# 冻结这批 3 秒(60 tick)
data modify storage zx:work fz set value {target:"",ticks:60}
$data modify storage zx:work fz.target set value "@e[type=!#sweetdream:no_damage,tag=zx.ef_$(uuid),distance=0..]"
function sweetdream:lib/freeze with storage zx:work fz

# 到点时刻 = 现在 + 60 tick —— 只有**基础版**用(3 秒后一次性结算)
scoreboard players operation #ef_due zx.meta = #now manacore.meta
scoreboard players add #ef_due zx.meta 60

# ★★ 超限版的两个时刻(和基础版分开写, 别混) ★★
#   pn  = 下一拍: 第一次在**施法后 20 tick(1 秒)** —— 冻结期间就开始打,
#         不是"冻完 3 秒才开始"(2026-10-08 用户指出: 原文是边冻边打)。
#   cap = 硬上限: 施法后 200 tick(10 秒) —— 到点剩下的全部收尾。
scoreboard players operation #ef_pn zx.meta = #now manacore.meta
scoreboard players add #ef_pn zx.meta 20
scoreboard players operation #ef_cap zx.meta = #now manacore.meta
scoreboard players add #ef_cap zx.meta 200

# 记账(施法者名下)
#   ol  = 敲没敲超限(拍的是施法那一刻的快照) —— 结算拖 3~10 秒, 那时手里那把已不准
#   p   = 超限版"每秒那一下"已经打了几次(最多 10 次, 见 pulse_ol)
#   pn  = 超限版"下一拍"的绝对时刻(★ 必须记, 见下)
#   cap = 超限版 10 秒硬上限的绝对时刻
#      【为什么要有 pn】这段是**每 tick** 跑的(为了"冻 3 秒"精确到 tick),
#        而"每秒一次"的节拍不能跟着变成每刻一次 —— 不记下一拍的话 10 次脉冲
#        会在 10 刻(0.5 秒)里全打完, 表现就是"最后一秒突然连着炸好几下"
#        (2026-10-08 玩家报)。
$data modify storage zx:data ef."$(uuid)" set value {u0:0,u1:0,u2:0,u3:0,due:0,ol:0b,p:0,pn:0,cap:0}
$execute if data storage zx:work a{ol:1b} run data modify storage zx:data ef."$(uuid)".ol set value 1b
$data modify storage zx:data ef."$(uuid)".u0 set from storage manacore:players "$(uuid)".u0
$data modify storage zx:data ef."$(uuid)".u1 set from storage manacore:players "$(uuid)".u1
$data modify storage zx:data ef."$(uuid)".u2 set from storage manacore:players "$(uuid)".u2
$data modify storage zx:data ef."$(uuid)".u3 set from storage manacore:players "$(uuid)".u3
$execute store result storage zx:data ef."$(uuid)".due int 1 run scoreboard players get #ef_due zx.meta
$execute store result storage zx:data ef."$(uuid)".pn int 1 run scoreboard players get #ef_pn zx.meta
$execute store result storage zx:data ef."$(uuid)".cap int 1 run scoreboard players get #ef_cap zx.meta

# 告诉 cast "冻上了"
data modify storage zx:work a.locked set value 1b

# 表现: 每只被冻生物身上一撮霜花 + 一声冰裂
$execute at @e[tag=zx.ef_$(uuid)] run particle minecraft:snowflake ~ ~1 ~ 0.4 0.6 0.4 0.02 24 normal
$execute at @e[tag=zx.ef_$(uuid)] run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.6 1.6

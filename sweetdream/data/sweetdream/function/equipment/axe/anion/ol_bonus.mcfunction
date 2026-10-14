# ============================================================
# sweetdream:equipment/axe/anion/ol_bonus —— 超限·负离子的"8 秒雷劲"
# ------------------------------------------------------------
# 【原文】"之后 8 秒内自身召唤闪电时闪电额外对落地处造成相当于自身当前魔力值
#   ×0.1 的伤害"
# 【谁调用它】lib/on_lightning(每一道"自己召唤的雷"落地时)
# 【执行者】召唤那道雷的玩家   【位置】**落点**(调用方已 at 过去)
# 【★ 为什么单独一个文件 ★】它既要"当前魔力"口径(走 other_mul, 基数由框架取
#   面板当前魔力), 又要以玩家身份发起伤害(击杀归属) —— 这套定式和 anion/cast ⑧
#   完全一样, 抄一份放这儿, 免得为了复用去动 cast 的控制流。
# 【范围】落点 2 格内全部生物(原版真闪电本身的雷击伤害是另一回事; 这一下是
#   文案里"额外的"那部分)。想改半径就改下面那一行。
# ★★ 【位置 = 调用方给的落点, 本文件里不许再 `at @s`】★ 2026-10-13 修: 原来 ②
#   写成 `execute at @s run tag @e[…distance=..2]`, @s 是玩家 ⇒ 范围变成"玩家周围
#   2 格"而不是"落地处 2 格" ⇒ 离玩家远的雷一点追加伤害都没有。
# 【诊断锚 #an_dbg1..3】(与 on_lightning 的 #an_dbg0 合成四级链, 探针看
#   debug/lightning_probe): 1=进了窗口 / 2=落点圈到生物 / 3=伤害已结算。
#   哪一级不涨, 链就断在那一级。
# ============================================================

# ① 拿 uuid(没有它就算不出"自身魔力值"口径的分身数据)
# 锚注释: 锚 1: 进了窗口(雷劲 >0)
scoreboard players add #an_dbg1 zx.meta 1
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 圈落点 2 格内的生物(位置就是落点, **不加 at @s** —— 加了就退回"玩家 2 格")
tag @e[tag=zx.an_ex,distance=0..] remove zx.an_ex
tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.an_ex
execute unless entity @e[tag=zx.an_ex,distance=0..] run return 0
# 锚注释: 锚 2: 落点 2 格内圈到了生物
scoreboard players add #an_dbg2 zx.meta 1

# ③ 伤害 = 自身当前魔力值 ×0.1(other_mul 的基数默认就是"当前魔力")
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.an_ex,distance=0..]",read:"manacore"}
function sweetdream:api/damage
# 锚注释: 锚 3: 伤害真的打出去了
scoreboard players add #an_dbg3 zx.meta 1

# ④ 表现 + 清标记(同样在**落点**, 不加 at @s)
particle minecraft:electric_spark ~ ~1 ~ 1.2 0.8 1.2 0.08 24 normal
playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.5 1.6
tag @e[tag=zx.an_ex,distance=0..] remove zx.an_ex

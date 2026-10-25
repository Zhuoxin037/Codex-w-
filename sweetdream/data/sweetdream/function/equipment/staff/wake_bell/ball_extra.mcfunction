# ============================================================
# sweetdream:equipment/staff/wake_bell/ball_extra —— 普攻命中「白昼梦」者的追加伤害
# ------------------------------------------------------------
# 【谁调用它】ball_hit ③   【执行者】**发射者玩家**   【位置】命中点(as 不改位置)
# 【技能原文】"每次普攻命中后若其附有「白昼梦」，则额外造成一次相当于自身最大魔力值
#   ×0.02 的伤害。"
# 【★ 打谁 ★】zx.ball_hit(这一发命中的那批)里**仍然带着「白昼梦」**的那些。
#   只打带状态的那几只 —— 不是整片命中者都吃追加。
# 【★ 为什么 at @s ★】api/damage 的 target 是选择器字符串, 内部 execute as 逐个打;
#   这里把位置定到玩家身上没有副作用(distance=0.. 无上限, 同维度即可)。
# ============================================================

# ① 算追加伤害 = 最大魔力值 ×0.02
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.02,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打(只打命中者里带「白昼梦」的)
data modify storage zx:in arg set value {target:"@e[tag=zx.ball_hit,distance=0..,tag=zx.status.dream]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ③ 表现: 梦被敲了一下
execute at @e[tag=zx.ball_hit,distance=0..,tag=zx.status.dream,limit=1] run particle minecraft:witch ~ ~1 ~ 0.4 0.5 0.4 0.02 12 normal
execute at @e[tag=zx.ball_hit,distance=0..,tag=zx.status.dream,limit=1] run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.4 1.4

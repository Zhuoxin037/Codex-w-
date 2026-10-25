# ============================================================
# sweetdream:equipment/staff/pour_sack/attack —— 倾囊: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(必须和这里对上)】✦ 普攻   魔力 60 · 伤害 12
# ★ 2026-10-21 定价口径（用户定：按整体主动技能消耗对齐）★
#   本件主动 = 当前魔力 40%（上限 1070 时约 428），落在「主动 400~550」这一档，
#   同档先例普攻 60~80；本件是**稀有**（同批最低档），取该档下沿 60。
#   伤害跟着降到 12 —— 与"每 5 点消耗换 1 点固定伤害"的主动换算同一量级
#   （60 ÷ 5 = 12），不再出现"稀有件的普攻比史诗件更痛"的倒挂。
# 【伤害口径】固定伤害 -> custom_damage 通道(不参与任何乘区), 与主动技能同源。
# 【★ 法杖普攻的固定范式 ★】(与 other_shore / late_court / apocalypse 同构):
#   gate -> uuid -> 超限快照 -> skill/check -> mana/consume -> 超限 mod
#   -> damage/calc -> 装球 -> equipment/staff/attack
# ============================================================

# ① 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)
#   ★ 必须排在**扣魔力之前**: 拦晚了就成了"扣了蓝但没出手"。
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ①.3 超限分档（批 K8）：普攻固定伤害 12→16（魔力 60 不变）
scoreboard players set #ps_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["pour_sack"],ol:"pour_sack"}] run scoreboard players set #ps_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["pour_sack"],ol:"pour_sack"}] run scoreboard players set #ps_ol zx.meta 1

# ② 只读检查: 魔力 80(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:ps_attack",mana:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #ps_need zx.meta 0
execute store result score #ps_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ps_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 80(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ps_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ ★ 2026-10-21 改回模板写法 ★ 原来是"跳过 damage/calc、手写 dmg:16.0 + fixed:1b",
#   全包 22 件法杖里只有这一件这么干。现在照 bent_ray(折径)的固定伤害范式:
#   走 damage/calc 的 custom_damage(不参与三条通道), 再让法球带着 r.damage 飞。
#   fixed:1b 仍然带上 —— 它的语义是"受击侧乘区也不吃"(见 internal/damage/one),
#   与本件"钉子的伤害一点都不走加成"的文案一致。
data modify storage manacore:in arg set value {uuid:"",custom_damage:12.0}
execute if score #ps_ol zx.meta matches 1 run data modify storage manacore:in arg.custom_damage set value 16.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去(固定伤害带 fixed, 不吃受击乘区)
data modify storage zx:work ball set value {dmg:0.0,fixed:1b,style:"pour_sack"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack

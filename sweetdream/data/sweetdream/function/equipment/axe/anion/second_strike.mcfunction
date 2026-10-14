# ============================================================
# sweetdream:equipment/axe/anion/second_strike —— 超限·负离子: 1 秒后的第二道雷
# ------------------------------------------------------------
# 【原文】"…1 秒后再释放闪电并对其相当于自身最大魔力值 ×0.08 的伤害。"
# 【谁调用它】core/tick: as @a[scores={zx.an_2nd=1..}] at @s run 本函数
# 【执行者】施法者   【位置】他所在处
# 【计时】zx.an_2nd 起手 20(刻), 每刻 -1, 减到 0 那一次正好过了 1 秒。
#   ★ 为什么不用 lib/second: 每秒扫会把"1 秒后"落成 1~2 秒之间的某一刻;
#     这里同永霜那条(见 core/tick 的说明), 要精确到 tick 就挂每刻。
# 【★ 这一下用**最大**魔力口径 ★】文案写的是"最大魔力值 ×0.08"(第一下才是当前魔力),
#   所以走 max_mana_mul 通道, 基数由框架自己取面板最大魔力。
# ============================================================

# ① 倒计时
scoreboard players remove @s zx.an_2nd 1
execute if score @s zx.an_2nd matches 1.. run return 0

# ② 圈出"此刻 6 格内的全部生物"
tag @e[tag=zx.an_hit2] remove zx.an_hit2
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..6] add zx.an_hit2

# ③ 逐个放闪电(位置 = 目标身上, @s 仍是玩家 -> 归属与雷劲钩子都对)
execute at @e[tag=zx.an_hit2] run summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_own"]}
execute at @e[tag=zx.an_hit2] run function sweetdream:lib/on_lightning

# ④ 伤害 = 自身最大魔力值 ×0.08
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.an_hit2]",read:"manacore"}
execute if entity @e[tag=zx.an_hit2] run function sweetdream:api/damage

# ⑤ 表现 + 清标记
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 1.4 0.8 1.4 0.08 40 normal
execute at @s run playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.8 1.1
tag @e[tag=zx.an_hit2] remove zx.an_hit2

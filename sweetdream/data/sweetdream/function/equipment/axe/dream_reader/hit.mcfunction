# ============================================================
# sweetdream:equipment/axe/dream_reader/hit —— 释梦 · 被动技能(平A钩子)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/dream_reader_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   基础: "攻击处于时停状态的生物时对其额外造成 5×剩余时停时间的真实伤害，之后解除他的
#          时停状态。"
#   超限(第三十三批, 2026-10-10): "攻击处于时停状态的生物时对其额外造成相当于自身基础
#          攻击力（最低为10）*剩余时停时间*0.5的真实伤害，之后解除他的时停状态。"
#     ★ 只有**倍率**变了: 5×剩余秒数 -> 基础攻击力(下限 10) × 剩余秒数 ×0.5。
#       "解除其时停"两段都有, 不变。剩余时停时间的单位沿用基础版口径 = **秒**
#       ((zx.ts_end − #now) ÷ 20, 下限 0)。
# 【★ 四要素逐个落实 ★】
#   ① 触发: 平A命中。
#   ② 目标范围: 命中的那一只, 且**必须处于时停**(tag=zx.stop)。
#   ③ 次数: 每次命中一次(这个钩子是"攻击到生物"口径 —— 只对"被点到的、且在时停里的那只"生效;
#      横扫扫到别的生物不会给它们加伤, 所以**不需要**按刻去重)。
#   ④ 时长: 瞬发; 打完之后**解除其时停**(lib/timestop_one)。
# 【数值】5 × 剩余时停秒数; 剩余秒数 = (zx.ts_end − #now) ÷ 20, 下限 0。
# 【伤害类型】sweetdream:true_damage(穿甲 + 不被无敌帧吃, 见 mirage/ts_dmg 的说明)。
# 【为什么用 lib/victim】命中的是哪一只, 只能从"刚挨打的最近一只"反查(见 lib/victim)。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/dream_reader_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是释梦才生效
scoreboard players set #dr_ok zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["dream_reader"]}] run scoreboard players set #dr_ok zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["dream_reader"]}] run scoreboard players set #dr_ok zx.meta 1
execute unless score #dr_ok zx.meta matches 1 run return 0

# ① 定位"刚才这一下打的是哪一只"
function sweetdream:lib/victim

# ② 它必须在时停里, 否则整个被动不触发
execute unless entity @e[tag=zx.victim,tag=zx.stop,distance=0..,limit=1] run return 0

# ③ 剩余时停秒数 = (zx.ts_end − #now) ÷ 20
scoreboard players set #dr_rem zx.meta 0
execute store result score #dr_rem zx.meta run scoreboard players get @e[tag=zx.victim,tag=zx.stop,distance=0..,limit=1] zx.ts_end
scoreboard players operation #dr_rem zx.meta -= #now manacore.meta
execute if score #dr_rem zx.meta matches ..0 run scoreboard players set #dr_rem zx.meta 0
scoreboard players operation #dr_rem zx.meta /= #20 zx.meta

# ③' 是不是超限版(用法同 cast: 主手或副手那件带 ol:"dream_reader")
scoreboard players set #dr_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["dream_reader"],ol:"dream_reader"}] run scoreboard players set #dr_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["dream_reader"],ol:"dream_reader"}] run scoreboard players set #dr_ol zx.meta 1

# ③'' 伤害 = 基础版 5 × 剩余秒数 / 超限版 基础攻击力(最低 10) × 剩余秒数 ×0.5
#   ★ 超限版那段单独抽成 ol_hit_dmg(要读 manacore 的 base_attack), 出参 #dr_dmg = 攻击力×100×秒数,
#     最后统一 ×0.005 变回实数 ⇒ 攻击力 × 秒数 × 0.5。
execute if score #dr_ol zx.meta matches 1 run function sweetdream:equipment/axe/dream_reader/ol_hit_dmg
execute if score #dr_ol zx.meta matches 0 run scoreboard players operation #dr_dmg zx.meta = #dr_rem zx.meta
execute if score #dr_ol zx.meta matches 0 run scoreboard players operation #dr_dmg zx.meta *= #5 zx.meta

# ④ 真实伤害(带玩家归属)
data modify storage zx:work a set value {damage:0.0}
execute if score #dr_ol zx.meta matches 0 store result storage zx:work a.damage double 1 run scoreboard players get #dr_dmg zx.meta
execute if score #dr_ol zx.meta matches 1 store result storage zx:work a.damage double 0.005 run scoreboard players get #dr_dmg zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.victim,distance=0..]"
data modify storage zx:work a.type set value "sweetdream:true_damage"
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑤ 解除其时停(逐只调用 lib/timestop_one)
execute as @e[tag=zx.victim,tag=zx.stop,distance=0..] run function sweetdream:lib/timestop_one

# ⑥ 表现: 梦醒的碎光
execute at @e[tag=zx.victim,distance=0..,limit=1] run particle minecraft:end_rod ~ ~1 ~ 0.4 0.5 0.4 0.03 14 normal
execute at @e[tag=zx.victim,distance=0..,limit=1] run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.7 1.4

# ⑦ 清标记
tag @e[tag=zx.victim,distance=0..] remove zx.victim

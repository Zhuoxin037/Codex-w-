# ============================================================
# sweetdream:equipment/sword/crescent/freeze_end —— 冻结窗结束: 6 格内结算
# ------------------------------------------------------------
# 【谁调用它】freeze_tick(窗归零那一拍, 宏 {uuid})   【执行者】施法者玩家
# 【原文】"6 秒结束时，对 6 格内全部目标造成相当于最大魔力 ×0.12 + 基础攻击力 ×4 的
#   伤害，之后被冻结的技能继续正常冷却。"
# 【伤害】max_mana_mul 0.12 + attack_mul 4.0, 再乘独立乘区 (1 + zx.cr_b/100)。
# 【收尾】清掉名单(zx:freeze p."<uuid>")—— 下一轮 cast 会重新拍。
# ============================================================

# ① 清名单
$data modify storage zx:freeze p."$(uuid)" set value {s0:"",s1:"",s2:"",s3:"",s4:"",s5:"",s6:"",s7:"",s8:""}

# ② 算伤害(独立乘区 = (100 + cr_b)/100)
scoreboard players set #cr_x zx.meta 100
scoreboard players operation #cr_x zx.meta += @s zx.cr_b
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12,attack_mul:4.0,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.independent_multiplier double 0.01 run scoreboard players get #cr_x zx.meta
function manacore:api/damage/calc

# ③ 圈"自身 6 格内全部", 一次性打出去
tag @e[tag=zx.cr_hit,distance=0..] remove zx.cr_hit
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..6] add zx.cr_hit
data modify storage zx:in arg set value {target:"@e[tag=zx.cr_hit]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s if entity @e[tag=zx.cr_hit,limit=1] run function sweetdream:api/damage
tag @e[tag=zx.cr_hit,distance=0..] remove zx.cr_hit

# ④ 收尾: 清加成计数 + 表现(一圈月华炸开)
scoreboard players set @s zx.cr_b 0
execute at @s run particle minecraft:end_rod ~ ~1 ~ 3.0 0.6 3.0 0.06 90 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 2.0 0.8 2.0 0.1 40 normal
execute at @s run playsound minecraft:entity.player.attack.strong player @a ~ ~ ~ 1.0 0.7
execute at @s run playsound minecraft:entity.breeze.wind_burst player @a ~ ~ ~ 0.5 1.6

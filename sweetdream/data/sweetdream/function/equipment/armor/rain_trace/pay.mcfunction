# ============================================================
# sweetdream:equipment/armor/rain_trace/pay —— 兑现「停满 2 秒」（执行者 = 水迹 marker）
# ------------------------------------------------------------
# 【谁调用它】dot_tick ③（水迹 1.6 格内还有"停留中"的生物时才跑）
# 【做什么】① 逐只判是否停够 40 刻 → 打 zx.rt_pay
#          ② 附「渊海」（tag/mark）
#          ③ 吃一次 释放者基础攻击力 ×2 的伤害（出生时算好，存在 marker NBT）
#          ④ 把这只置 zx.rt_on = 2（本段水迹对同一只**只结算一次**）
# 【技能原文】"…对在水迹处持续停留 2 秒的生物附加「渊海」，并使其受到一次相当于
#   释放者基础攻击力 ×2 的伤害。"
# 【★ 顺序：先附状态、后打伤害 ★】文案写的顺序如此；而且「渊海」是很多装备的
#   触发条件（回潮扣/杂纹/彼岸…），先附上再让这一下伤害进 calc 链，语义才一致。
# 【★ 伤害归属 ★】marker NBT 里存了释放者 UUID 四整数，交给 with_from 做 by 归属；
#   玩家中途离线时 with_from 会退回"无归属"的写法（不会静默丢伤害）。
# ============================================================

tag @e[tag=zx.rt_pay,distance=..16] remove zx.rt_pay
execute as @e[type=!#sweetdream:no_damage,distance=..1.6,scores={zx.rt_on=1}] run function sweetdream:equipment/armor/rain_trace/pay_one
execute unless entity @e[tag=zx.rt_pay,distance=..16] run return 0

# ① 附「渊海」
data modify storage zx:work t set value {target:"@e[tag=zx.rt_pay,distance=..16]",mark:"yuanhai"}
function sweetdream:tag/mark with storage zx:work t

# ② 伤害 = 释放者基础攻击力 ×2（出生那一刻的快照）
data modify storage zx:work a set value {target:"@e[tag=zx.rt_pay,distance=..16]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 本段水迹对这只不再重复结算
scoreboard players set @e[tag=zx.rt_pay,distance=..16] zx.rt_on 2

# ④ 表现
execute at @e[tag=zx.rt_pay,distance=..16] run particle minecraft:splash ~ ~0.4 ~ 0.4 0.4 0.4 0 12 normal
execute at @e[tag=zx.rt_pay,distance=..16] run particle minecraft:dust{color:[0.3,0.55,0.75],scale:1.2} ~ ~0.5 ~ 0.3 0.3 0.3 0 8 normal
execute at @e[tag=zx.rt_pay,distance=..16] run playsound minecraft:entity.player.splash player @a ~ ~ ~ 0.7 1.0

tag @e[tag=zx.rt_pay,distance=..16] remove zx.rt_pay

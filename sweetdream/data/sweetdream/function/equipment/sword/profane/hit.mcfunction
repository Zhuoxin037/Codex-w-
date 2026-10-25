# ============================================================
# sweetdream:equipment/sword/profane/hit —— 剖心（下界剑 · 普攻被动）
# ------------------------------------------------------------
# 【触发】玩家普攻命中（advancement player_hurt_entity + is_player_attack）
# 【技能原文】
#   魔力 80 · 伤害 1
#   未超限: "每次普攻命中附有「噬心」的生物时，使其「噬心」的剩余时长延长 2 秒（最多 18 秒），
#    并额外造成相当于自身基础攻击力的伤害。该效果 5 秒内最多触发一次。"
#   超限·剖心(2026-10-23 批 K2): 延长 2 -> **3 秒**、上限 18 -> **24 秒**;
#    其余(额外伤害 ×1、5 秒限频)不变 —— 原文没提限频, 就按"只改说到的部分"。
# 【为什么先判满蓄力】包内所有"普攻附带"件（秤星 / 归息 / 回旋）都先走 lib/atk_charge：
#   不满蓄力的一下不算"命中"，否则连点能无限延长噬心。
# 【上限怎么夹】噬心施加时满值 18（tag/mark_one），但**超限的延长能顶到 24** ——
#   "延长"不等于"重新施加", 所以上限不复用 mark_one 的 18, 而是 hit 自己的 #pf_cap。
# 【限频】zx.pf_poke = 下次可触发的**绝对刻**（#now + 100）。没有分数时比较失败，
#   正好等于"从没触发过"，不需要额外初始化。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/profane_hit

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["profane"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["profane"]}] run return 0

# 【超限分档 2026-10-23 批 K2】未超限 +2 秒 / 上限 18 -> 超限 +3 秒 / 上限 24
#   ★ "延长"能超过施加时的满值(18) —— 超限下上限才是 24, 所以不能沿用 mark_one 的 18。
#   ★ #pf_ol 只在这一次函数调用里"设 + 用", 不跨刻, 没有串号窗口。
scoreboard players set #pf_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["profane"],ol:"profane"}] run scoreboard players set #pf_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["profane"],ol:"profane"}] run scoreboard players set #pf_ol zx.meta 1

scoreboard players set #pf_add zx.meta 2
scoreboard players set #pf_cap zx.meta 18
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #pf_add zx.meta 3
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #pf_cap zx.meta 24

function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=..16,limit=1] run return 0

# 5 秒限频
execute if score @s zx.pf_poke > #now manacore.meta run return 0

# 目标必须附有噬心，否则这次普攻不带任何附加
execute unless entity @e[tag=zx.victim,distance=..16,limit=1,tag=zx.status.shixin] run return 0

# ---- ① 延长(未超限 2 秒夹 18 / 超限 3 秒夹 24)----
execute as @e[tag=zx.victim,distance=..16,limit=1] run scoreboard players operation @s zx.tt.shixin += #pf_add zx.meta
execute as @e[tag=zx.victim,distance=..16,limit=1] if score @s zx.tt.shixin > #pf_cap zx.meta run scoreboard players operation @s zx.tt.shixin = #pf_cap zx.meta

# ---- ② 额外伤害 = 基础攻击力 ×1 ----
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:work a set value {target:"@e[tag=zx.victim,distance=..16,limit=1]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ---- ③ 记限频：下次可用 = 现在 + 100 刻 ----
scoreboard players operation @s zx.pf_poke = #now manacore.meta
scoreboard players add @s zx.pf_poke 100

execute at @e[tag=zx.victim,distance=..16,limit=1] run particle minecraft:dust{color:[0.5,0.06,0.1],scale:1.2} ~ ~1 ~ 0.4 0.5 0.4 0.02 14 normal
execute at @e[tag=zx.victim,distance=..16,limit=1] run playsound minecraft:entity.breeze.wind_burst player @a ~ ~ ~ 0.5 1.5
tag @e[tag=zx.victim] remove zx.victim

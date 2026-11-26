$execute unless entity $(vx_uuid) run return 0

# 5 秒限频
execute if score @s zx.pf_poke > #now manacore.meta run return 0

# 目标必须附有噬心，否则这次普攻不带任何附加
$execute unless data entity $(vx_uuid) {Tags:["zx.status.shixin"]} run return 0

# ---- ① 延长(未超限 2 秒夹 18 / 超限 3 秒夹 24)----
$execute as $(vx_uuid) run scoreboard players operation @s zx.tt.shixin += #pf_add zx.meta
$execute as $(vx_uuid) if score @s zx.tt.shixin > #pf_cap zx.meta run scoreboard players operation @s zx.tt.shixin = #pf_cap zx.meta

# ---- ② 额外伤害 = 基础攻击力 ×1 ----
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

$data modify storage zx:work a set value {target:"$(vx_uuid)",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function fallendream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function fallendream:internal/attack/submit_extra

# ---- ③ 记限频：下次可用 = 现在 + 100 刻 ----
scoreboard players operation @s zx.pf_poke = #now manacore.meta
scoreboard players add @s zx.pf_poke 100

$execute at $(vx_uuid) run particle minecraft:dust{color:[0.5,0.06,0.1],scale:1.2} ~ ~1 ~ 0.4 0.5 0.4 0.02 14 normal
$execute at $(vx_uuid) run playsound minecraft:entity.breeze.wind_burst player @a ~ ~ ~ 0.5 1.5
$tag $(vx_uuid) remove zx.victim

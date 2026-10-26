execute unless score @s zx.job matches 2 run return 0
execute if score @s zx.j_b_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.j_b_lt = #now manacore.meta
execute store result score #jbhp zx.meta run data get entity @s Health 1000
execute store result score #jbmax zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #jbhalf zx.meta = #jbmax zx.meta
scoreboard players operation #jbhalf zx.meta /= #j2 zx.meta
execute unless score #jbhp zx.meta > #jbhalf zx.meta run return 0
scoreboard players operation #jbself zx.meta = #jbmax zx.meta
scoreboard players operation #jbself zx.meta /= #j10 zx.meta
execute store result storage zx:work jbself.amount double 0.001 run scoreboard players get #jbself zx.meta
function sweetdream:profession/berserker/self_damage with storage zx:work jbself
scoreboard players operation #jbhp zx.meta -= #jbself zx.meta
execute if score @s zx.j_aw matches 1 if score #jbhp zx.meta <= #jbhalf zx.meta run effect give @s minecraft:resistance 5 2 true
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #mp_src zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #mp_mul zx.meta 300
function sweetdream:lib/math/mul_permille
scoreboard players operation #jbbonus zx.meta = #mp_out zx.meta
function sweetdream:profession/berserker/expire
scoreboard players set #jbslot zx.meta 0
execute unless score @s zx.j_b_t1 > #now manacore.meta run scoreboard players set #jbslot zx.meta 1
execute if score @s zx.j_aw matches 1 if score #jbslot zx.meta matches 0 unless score @s zx.j_b_t2 > #now manacore.meta run scoreboard players set #jbslot zx.meta 2
execute if score @s zx.j_aw matches 1 if score #jbslot zx.meta matches 0 unless score @s zx.j_b_t3 > #now manacore.meta run scoreboard players set #jbslot zx.meta 3
execute if score #jbslot zx.meta matches 1 run scoreboard players operation @s zx.j_b_v1 = #jbbonus zx.meta
execute if score #jbslot zx.meta matches 1 run scoreboard players operation @s zx.j_b_t1 = #now manacore.meta
execute if score #jbslot zx.meta matches 1 run scoreboard players add @s zx.j_b_t1 160
execute if score #jbslot zx.meta matches 2 run scoreboard players operation @s zx.j_b_v2 = #jbbonus zx.meta
execute if score #jbslot zx.meta matches 2 run scoreboard players operation @s zx.j_b_t2 = #now manacore.meta
execute if score #jbslot zx.meta matches 2 run scoreboard players add @s zx.j_b_t2 160
execute if score #jbslot zx.meta matches 3 run scoreboard players operation @s zx.j_b_v3 = #jbbonus zx.meta
execute if score #jbslot zx.meta matches 3 run scoreboard players operation @s zx.j_b_t3 = #now manacore.meta
execute if score #jbslot zx.meta matches 3 run scoreboard players add @s zx.j_b_t3 160
# At cap, refresh the oldest surviving stack; keep its recorded value.
execute if score #jbslot zx.meta matches 0 run function sweetdream:profession/berserker/refresh_oldest
function sweetdream:profession/berserker/apply

advancement revoke @s only fallendream:equipment/sword/wound_stitch
execute unless score @s zx.job matches 2 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 2 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:wound_stitch",mana:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
scoreboard players add @s zx.ws_wound 0
execute unless score @s zx.ws_until > #now manacore.meta run function fallendream:equipment/sword/wound_stitch/expire
scoreboard players operation #wst_wound zx.meta = @s zx.ws_wound
function fallendream:equipment/sword/wound_stitch/expire
execute store result score #wst_hp zx.meta run data get entity @s Health 1000
execute store result score #wst_max zx.meta run attribute @s minecraft:max_health get 1000
execute if entity @s[tag=zx.nr_clamp] run function fallendream:lib/max_health_score
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #wst_max zx.meta = #max_hp zx.meta
scoreboard players set #wst_two zx.meta 2
scoreboard players operation #wst_half zx.meta = #wst_max zx.meta
scoreboard players operation #wst_half zx.meta /= #wst_two zx.meta
scoreboard players set #wst_high zx.meta 0
execute if score #wst_hp zx.meta > #wst_half zx.meta run scoreboard players set #wst_high zx.meta 1
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:wound_stitch",cooldown_seconds:24.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
function fallendream:equipment/sword/wound_stitch/select
data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0}
execute if score #wst_high zx.meta matches 1 run data modify storage manacore:in arg.attack_mul set value 7.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[tag=zx.ws_target,distance=0..]",type:"fallendream:skill",wound_hit:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function fallendream:lib/num/plain
tag @e[tag=zx.ws_landed,distance=0..] remove zx.ws_landed
function fallendream:internal/attack/submit_skill
execute if score #wst_high zx.meta matches 0 if entity @e[tag=zx.ws_landed,distance=0..,limit=1] run function fallendream:equipment/sword/wound_stitch/heal
function fallendream:equipment/sword/wound_stitch/prepare_delay
tag @e[tag=zx.ws_target,distance=0..] remove zx.ws_target
tag @e[tag=zx.ws_landed,distance=0..] remove zx.ws_landed

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work burial_owner set value {owner:""}
data modify storage zx:work burial_owner.owner set from storage zx:data self.uuid
scoreboard players set #burial_found zx.meta 0
function fallendream:equipment/staff/star_burial/detonate_owned with storage zx:work burial_owner
execute if score #burial_found zx.meta matches 1 run return 0
tag @e[tag=zx.burial_pick,distance=0..] remove zx.burial_pick
scoreboard players set #burial_steps zx.meta 0
execute anchored eyes run function fallendream:equipment/staff/star_burial/ray
execute unless entity @e[tag=zx.burial_pick,distance=0..,limit=1] run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:star_burial",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:star_burial",cooldown_seconds:65.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
function fallendream:lib/uuid
scoreboard players add @s zx.j_orb 0
scoreboard players operation #burial_orbs zx.meta = @s zx.j_orb
function fallendream:equipment/armor/eagle_hat/orb_before
scoreboard players set @s zx.j_orb 0
function fallendream:equipment/armor/eagle_hat/orb_after
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #mp_src zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #mp_mul zx.meta = #burial_orbs zx.meta
scoreboard players set #burial_hundred zx.meta 100
scoreboard players operation #mp_mul zx.meta *= #burial_hundred zx.meta
function fallendream:lib/math/mul_permille
scoreboard players operation #burial_cap zx.meta = #mp_out zx.meta
data modify storage zx:work burial_create set value {owner:"",u0:0,u1:0,u2:0,u3:0,target:""}
data modify storage zx:work burial_create.owner set from storage zx:data self.uuid
execute store result storage zx:work burial_create.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work burial_create.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work burial_create.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work burial_create.u3 int 1 run scoreboard players get @s manacore.u3
execute as @e[tag=zx.burial_pick,distance=0..,limit=1] at @s run function fallendream:equipment/staff/star_burial/create
tag @e[tag=zx.burial_pick,distance=0..] remove zx.burial_pick

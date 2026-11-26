scoreboard players add @s zx.et_fox 0
execute unless score @s zx.et_fox matches 1.. run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:eight_tail",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
scoreboard players operation #fox8_x zx.meta = @s zx.et_fox
scoreboard players set @s zx.et_fox 0
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:eight_tail",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
execute if score #fox8_x zx.meta matches ..0 run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work fox8 set value {x:0,damage:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work fox8.x int 1 run scoreboard players get #fox8_x zx.meta
execute store result storage zx:work fox8.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work fox8.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work fox8.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work fox8.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work fox8.damage set from storage manacore:out r.damage
data modify storage zx:work fox8.s2_b_damage set value {n:0,d:1}
data modify storage zx:work fox8.s2_b_damage set from storage manacore:out r.s2_b_damage
function fallendream:equipment/staff/eight_tail/prepare with storage zx:work fox8

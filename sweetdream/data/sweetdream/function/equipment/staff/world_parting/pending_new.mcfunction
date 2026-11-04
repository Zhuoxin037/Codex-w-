function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
execute if score #phase_enh zx.meta matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.12
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work phase4.num set from storage manacore:out r.damage
data modify storage zx:work phase4.s2_b_num set value {n:0,d:1}
data modify storage zx:work phase4.s2_b_num set from storage manacore:out r.s2_b_damage
data modify storage zx:work phase4.enh set value 0b
execute if score #phase_enh zx.meta matches 1 run data modify storage zx:work phase4.enh set value 1b
summon minecraft:marker ~ ~ ~ {Tags:["zx.wp_pending","zx.wp_new"],data:{}}
data modify entity @e[tag=zx.wp_new,distance=0..,limit=1] data set from storage zx:work phase4
scoreboard players operation @e[tag=zx.wp_new,distance=0..,limit=1] zx.wp_due = #now manacore.meta
scoreboard players add @e[tag=zx.wp_new,distance=0..,limit=1] zx.wp_due 10
tag @e[tag=zx.wp_new,distance=0..] remove zx.wp_new

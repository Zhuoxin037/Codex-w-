function sweetdream:lib/uuid
function sweetdream:profession/mod_begin {book_obj:"zx.j_pain_book",sor_obj:"zx.j_pain_sor"}
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.15}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
function sweetdream:profession/mod_end
data modify storage zx:work a set value {target:"@e[type=!#sweetdream:no_damage,distance=..5]",type:"sweetdream:skill",u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
execute if score @s zx.j_grace matches 1 run return 0
execute store result score #jpain zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players set #jpainmul zx.meta 800
scoreboard players operation #mp_src zx.meta = #jpain zx.meta
scoreboard players operation #mp_mul zx.meta = #jpainmul zx.meta
function sweetdream:lib/math/mul_permille
execute store result storage zx:work jpain.amount double 0.001 run scoreboard players get #mp_out zx.meta
function sweetdream:profession/mage/self_damage with storage zx:work jpain

scoreboard players add @s zx.j_ess 0
scoreboard players operation #jconsumed zx.meta = @s zx.j_ess
scoreboard players set @s zx.j_ess 0
scoreboard players operation #jtaken zx.meta = #jconsumed zx.meta
execute as @e[type=!#sweetdream:no_damage,distance=..3,scores={zx.j_ess=1..}] run function sweetdream:profession/twin/consume_near
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #mp_src zx.meta run data get storage manacore:out r.max 1000
scoreboard players operation #mp_mul zx.meta = #jtaken zx.meta
scoreboard players operation #mp_mul zx.meta *= #j10 zx.meta
function sweetdream:lib/math/mul_permille
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #mp_out zx.meta
function manacore:api/mana/add

advancement revoke @s only sweetdream:equipment/sword/contract_rift_hit
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless score @s zx.job matches 4 run return 0
execute unless score @s zx.j_form matches 1 run return 0
function sweetdream:lib/uuid
data modify storage zx:work crhit set value {owner:"",t0:0,t1:0,t2:0,t3:0}
data modify storage zx:work crhit.owner set from storage zx:data self.uuid
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=..16,limit=1] run return 0
execute store result storage zx:work crhit.t0 int 1 run data get entity @e[tag=zx.victim,distance=..16,limit=1] UUID[0]
execute store result storage zx:work crhit.t1 int 1 run data get entity @e[tag=zx.victim,distance=..16,limit=1] UUID[1]
execute store result storage zx:work crhit.t2 int 1 run data get entity @e[tag=zx.victim,distance=..16,limit=1] UUID[2]
execute store result storage zx:work crhit.t3 int 1 run data get entity @e[tag=zx.victim,distance=..16,limit=1] UUID[3]
function sweetdream:equipment/sword/contract_rift/melee_find with storage zx:work crhit
tag @e[tag=zx.victim,distance=0..] remove zx.victim

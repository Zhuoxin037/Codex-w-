tag @s add zx.cr_attacker
execute store result storage zx:work crguard.t0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work crguard.t1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work crguard.t2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work crguard.t3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/sword/contract_rift/body_match with storage zx:work crguard

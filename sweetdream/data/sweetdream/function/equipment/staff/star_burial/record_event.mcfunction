advancement revoke @s only sweetdream:equipment/staff/star_burial_hit
data modify storage zx:work burial_rec set value {a0:0,a1:0,a2:0,a3:0}
execute store result storage zx:work burial_rec.a0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work burial_rec.a1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work burial_rec.a2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work burial_rec.a3 int 1 run scoreboard players get @s manacore.u3
execute as @e[tag=zx.burial_core,distance=0..] at @s run function sweetdream:equipment/staff/star_burial/record_target with entity @s data

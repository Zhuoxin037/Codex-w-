execute store result storage sweetdream:husk aggro.id int 1 run scoreboard players get @s sdh.id
scoreboard players operation #aggro sdh.id = @s sdh.id
tag @e[tag=sd.hk.target,distance=0..] remove sd.hk.target
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,distance=..30,limit=1] at @s run function sweetdream:boss/husk/target/accept
$execute unless entity @e[tag=sd.hk.target,distance=0..] as @e[type=!minecraft:player,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=..30,limit=1] at @s run function sweetdream:boss/husk/target/accept
execute unless entity @e[tag=sd.hk.target,distance=0..] run return 0
data modify storage sweetdream:aggro out.success set value true
tag @e[tag=sd.hk.target,distance=0..] remove sd.hk.target

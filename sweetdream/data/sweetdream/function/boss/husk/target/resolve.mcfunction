# Player identity is resolved from cached integer UUIDs, not a 32-character player name.
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,distance=..30,limit=1] at @s run function sweetdream:boss/husk/target/valid
$execute unless entity @e[tag=sd.hk.target,distance=0..] as @e[type=!minecraft:player,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=..30,limit=1] at @s run function sweetdream:boss/husk/target/valid

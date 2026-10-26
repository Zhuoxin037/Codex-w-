$execute in minecraft:overworld as @e[type=!#sweetdream:no_damage,distance=0..,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]}] at @s run function sweetdream:internal/native/target {melee:$(melee),charged:$(charged),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute in minecraft:the_nether as @e[type=!#sweetdream:no_damage,distance=0..,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]}] at @s run function sweetdream:internal/native/target {melee:$(melee),charged:$(charged),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute in minecraft:the_end as @e[type=!#sweetdream:no_damage,distance=0..,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]}] at @s run function sweetdream:internal/native/target {melee:$(melee),charged:$(charged),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}

function sweetdream:internal/native/dead_scan

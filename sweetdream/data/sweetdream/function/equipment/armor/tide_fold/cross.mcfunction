$execute if entity @s[tag=zx.ball,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}] run tag @s add zx.tf_pass
$execute if entity @s[type=minecraft:player] at @s run function sweetdream:equipment/armor/tide_fold/cross_player {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3),id:$(id)}
execute unless entity @s[type=minecraft:player] if data entity @s Health at @s run function sweetdream:equipment/armor/tide_fold/cross_enemy

# 蒺藜每20刻一次伤害；缓慢由独立逐刻进出区管理。
data modify storage zx:work a set value {channel_atk:0.0,target:"@e[type=!#sweetdream:no_damage,distance=..2.5]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a


particle minecraft:crit ~ ~0.05 ~ 2.2 0.05 2.2 0.01 10 normal
particle minecraft:enchanted_hit ~ ~0.05 ~ 1.8 0.03 1.8 0.01 6 normal

scoreboard players add @s zx.tjl_next 20

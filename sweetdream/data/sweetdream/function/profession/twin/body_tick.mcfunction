data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=4,zx.j_form=1}] run function sweetdream:profession/twin/body_offline
execute unless entity @a[tag=zx.ub,scores={zx.job=4,zx.j_form=1}] run return 0
execute store result score #jem_bodyhp zx.meta run data get entity @s Health 1000
scoreboard players add @s zx.j_hurt_hp 0
scoreboard players set #jem_got zx.meta 0
execute if score @s zx.j_hurt_hp matches 1.. run scoreboard players operation #jem_got zx.meta = @s zx.j_hurt_hp
execute if score #jem_got zx.meta matches 1.. run scoreboard players operation #jem_got zx.meta -= #jem_bodyhp zx.meta
scoreboard players operation @s zx.j_hurt_hp = #jem_bodyhp zx.meta
execute if score #jem_got zx.meta matches 1.. as @a[tag=zx.ub,limit=1] if items entity @s weapon.mainhand *[custom_data~{zx:["empathy"]}] run function sweetdream:profession/twin/reflect
scoreboard players add @s zx.j_pulse 0
scoreboard players remove @s zx.j_pulse 1
execute if score @s zx.j_pulse matches ..0 run function sweetdream:profession/twin/taunt_scan

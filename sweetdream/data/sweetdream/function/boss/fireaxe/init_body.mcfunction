tag @s remove sd.fb.new
attribute @s minecraft:max_health base set 1000
attribute @s minecraft:scale base set 2.25
attribute @s minecraft:attack_damage base set 0
data modify entity @s Rotation set from entity @e[tag=sd.fb.current_rig,limit=1,distance=0..] Rotation
scoreboard players set @s sdbf.state 0
scoreboard players set @s sdbf.rest 30
scoreboard players set @s sdbf.dashcd 60
scoreboard players set @s sdbf.jumpcd 100
scoreboard players set @s sdbf.shortcd 40
scoreboard players set @s sdbf.age 0
scoreboard players set @s sdbf.blocked 0
scoreboard players set @s sdbf.last_hp 1000000
function sweetdream:boss/fireaxe/visual/carrier_label
scoreboard players set @s sdbf.phase 1
function sweetdream:boss/fireaxe/mechanics/init

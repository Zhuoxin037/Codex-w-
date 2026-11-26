function fallendream:equipment/staff/fate_thread/watch_end
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:ft frames append value {f:{owner:"",mode:0,main:"",a:[],b:[],count:0,end1:0,end2:0}}
data modify storage zx:ft frames[-1].f.owner set from storage zx:data self.uuid
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["fate_thread"],ol:"fate_thread"}] run data modify storage zx:ft frames[-1].f.mode set value 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["fate_thread"],ol:"fate_thread"}] run data modify storage zx:ft frames[-1].f.mode set value 1
tag @e[tag=zx.ft_select,distance=0..] remove zx.ft_select
execute if data storage zx:ft frames[-1].f{mode:0} run tag @e[type=!#fallendream:no_damage,tag=zx.status.shixin,distance=0.1..10,sort=nearest,limit=1] add zx.ft_select
execute if data storage zx:ft frames[-1].f{mode:1} run tag @e[type=!#fallendream:no_damage,tag=zx.status.shixin,distance=0.1..12,sort=nearest,limit=1] add zx.ft_select
execute as @e[tag=zx.ft_select,limit=1] run function fallendream:equipment/staff/fate_thread/capture_main
execute if data storage zx:ft frames[-1].f{mode:0} at @e[tag=zx.ft_select,limit=1] as @e[type=!#fallendream:no_damage,tag=!zx.ft_select,distance=0.01..6,sort=nearest,limit=2] run function fallendream:equipment/staff/fate_thread/capture_a
execute if data storage zx:ft frames[-1].f{mode:1} at @e[tag=zx.ft_select,limit=1] as @e[type=!#fallendream:no_damage,tag=!zx.ft_select,distance=0.01..6,sort=nearest,limit=6] run function fallendream:equipment/staff/fate_thread/capture_a
execute if data storage zx:ft frames[-1].f{mode:1} at @e[tag=zx.ft_select,limit=1] as @e[type=!#fallendream:no_damage,tag=zx.status.shixin,tag=!zx.ft_select,distance=0.01..12,sort=nearest,limit=4] run function fallendream:equipment/staff/fate_thread/capture_b
execute store result storage zx:ft frames[-1].f.end1 int 1 run scoreboard players get #now manacore.meta
scoreboard players operation @s zx.ft_end = #now manacore.meta
scoreboard players add @s zx.ft_end 140
execute if data storage zx:ft frames[-1].f{mode:1} run scoreboard players add @s zx.ft_end 100
execute store result storage zx:ft frames[-1].f.end1 int 1 run scoreboard players get @s zx.ft_end
scoreboard players set @s zx.ft2_end 0
execute if data storage zx:ft frames[-1].f{mode:1} run scoreboard players operation @s zx.ft2_end = #now manacore.meta
execute if data storage zx:ft frames[-1].f{mode:1} run scoreboard players add @s zx.ft2_end 360
execute store result storage zx:ft frames[-1].f.end2 int 1 run scoreboard players get @s zx.ft2_end
scoreboard players add #fate_cast zx.meta 1
scoreboard players operation @s zx.ft_mine = #fate_cast zx.meta
scoreboard players set @s zx.ft_got 0
function fallendream:equipment/staff/fate_thread/save_record with storage zx:ft frames[-1].f
data remove storage zx:ft frames[-1]
tag @e[tag=zx.ft_select,distance=0..] remove zx.ft_select
tag @s add zx.ft_link

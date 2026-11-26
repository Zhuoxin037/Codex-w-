$summon minecraft:item_display ~ ~ ~ {Tags:["sd.bs.fx","sd.bs.newfx"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"fallendream_boss:b_staff/fx_$(model)"}},item_display:"none",view_range:1f,width:4f,height:4f,interpolation_duration:1,teleport_duration:0,transformation:{translation:[0f,0f,0f],scale:[1f,1f,1f],left_rotation:[0f,1f,0f,0f],right_rotation:[0f,0f,0f,1f]}}
scoreboard players operation @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.owner = #owner bs.id
scoreboard players operation @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.cast = #cast bs.cast
scoreboard players operation @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.born = #clock bs.clock
scoreboard players operation @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.dmg = #damage bs.dmg
scoreboard players operation @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.limit = #limit bs.limit
scoreboard players operation @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.interval = #interval bs.interval
$scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.kind $(kind)
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.fage 0
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.life 32

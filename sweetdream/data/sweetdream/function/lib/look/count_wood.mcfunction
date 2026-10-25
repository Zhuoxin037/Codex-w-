scoreboard players set #hud_wood zx.meta 0
$execute as @e[tag=zx.gw_wood,distance=0..,nbt={data:{zx:{gd:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}] run scoreboard players add #hud_wood zx.meta 1
scoreboard players set #hud_res zx.meta 0
execute as @e[tag=zx.gw_wood,distance=..12] run scoreboard players add #hud_res zx.meta 1
execute if score #hud_res zx.meta matches 4.. run scoreboard players set #hud_res zx.meta 3
execute unless score #hud_wood zx.meta matches 1.. unless score #hud_res zx.meta matches 1.. run return 0
function sweetdream:lib/look/separator
data modify storage zx:look xline append value {text:"朽木 ",color:"dark_green"}
data modify storage zx:look xline append value {score:{name:"#hud_wood",objective:"zx.meta"},color:"green"}
data modify storage zx:look xline append value {text:"/3 附近抗性 ",color:"gray"}
data modify storage zx:look xline append value {score:{name:"#hud_res",objective:"zx.meta"},color:"green"}

execute if score @s zx.gl_wt matches 1.. if score @s zx.gl_wt <= #now manacore.meta run return 0
execute unless score @s zx.gl_r matches 1 unless score @s zx.gl_g matches 1 unless score @s zx.gl_y matches 1 run return 0
function sweetdream:lib/look/separator
execute if score @s zx.gl_wt > #now manacore.meta run return run function sweetdream:equipment/armor/glimmer/look_white
data modify storage zx:look xline append value {text:"浮光 ",color:"gray"}
execute if score @s zx.gl_r matches 1 run data modify storage zx:look xline append value {text:"红",color:"red"}
execute if score @s zx.gl_g matches 1 run data modify storage zx:look xline append value {text:"绿",color:"green"}
execute if score @s zx.gl_y matches 1 run data modify storage zx:look xline append value {text:"黄",color:"yellow"}

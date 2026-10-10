# Idle 5 fps; cast 10 fps. Update the real held item and preserve all other components.
scoreboard players add @s zx.slvi 1
execute if score @s zx.slvi matches 80.. run scoreboard players set @s zx.slvi 0
scoreboard players operation #frame zx.slvf = @s zx.slvi
scoreboard players operation #frame zx.slvf /= #4 zx.slvf
execute if score @s zx.sl_vt matches 1.. run scoreboard players operation #frame zx.slvf = @s zx.slva
execute if score @s zx.sl_vt matches 1.. run scoreboard players operation #frame zx.slvf /= #2 zx.slvf
execute if score @s zx.sl_vt matches 1.. run scoreboard players add #frame zx.slvf 100
# The final gameplay second uses the authored settling section.
execute if score @s zx.sl_vt matches 1 run scoreboard players operation #frame zx.slvf = @s zx.slve
execute if score @s zx.sl_vt matches 1 run scoreboard players operation #frame zx.slvf /= #2 zx.slvf
execute if score @s zx.sl_vt matches 1 run scoreboard players add #frame zx.slvf 130
scoreboard players set #mask zx.slvm 0
execute if score @s zx.sl_mask matches 0..15 run scoreboard players operation #mask zx.slvm = @s zx.sl_mask
data modify storage zx:work sail_visual set value {frame:0,mask:0}
execute store result storage zx:work sail_visual.frame int 1 run scoreboard players get #frame zx.slvf
execute store result storage zx:work sail_visual.mask int 1 run scoreboard players get #mask zx.slvm
function sweetdream:equipment/staff/sail/visual/apply with storage zx:work sail_visual

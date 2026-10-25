# 同一玩家重放前已经由skill的bb_on门控拦住；不动其他玩家的标签。
$execute at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.bb_ctrl","zx.bb_ctrl_$(uuid)"]}
$data modify entity @e[type=marker,tag=zx.bb_ctrl_$(uuid),limit=1,distance=..1] data.bb set from storage zx:work bb
scoreboard players operation #bb_probe_left zx.meta = @s zx.bb_left
$execute as @e[type=marker,tag=zx.bb_ctrl_$(uuid),limit=1,distance=..1] at @s rotated $(yaw) 0 run function sweetdream:equipment/staff/burst_bank/probe
$data modify entity @e[type=marker,tag=zx.bb_ctrl_$(uuid),limit=1] Pos set from entity @e[type=marker,tag=zx.bb_ctrl_$(uuid),limit=1] data.bb.origin
execute if score #bb_support zx.meta matches 0 run function sweetdream:equipment/staff/burst_bank/refund
execute if score #bb_support zx.meta matches 0 run scoreboard players set @s zx.bb_left 0
execute if score #bb_support zx.meta matches 0 run return run function sweetdream:equipment/staff/burst_bank/land
playsound minecraft:entity.ravager.roar player @a ~ ~ ~ 0.8 1.3
particle minecraft:sweep_attack ~ ~0.4 ~ 1.0 0.3 1.0 0 6 normal

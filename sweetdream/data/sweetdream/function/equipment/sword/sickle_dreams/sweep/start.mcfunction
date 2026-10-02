# 已通过魔力/冷却检查；这里只预约，等通用回手完成再动。
execute if score #sd_enh zx.meta matches 1 run function sweetdream:equipment/sword/sickle_dreams/area_wide
data modify storage zx:sweep record set value {targets:[],wait:0,enhanced:0,leave:0,hand:"weapon.mainhand"}
# 这一下是从哪只手放的(cast 判好的标签), 之后等待 / 判定 / 挥击帧 / 还原都按它走。
#   默认主手: 副手才改写。读完立刻清标签, 免得下一轮误判。
execute if entity @s[tag=zx.sd_off] run data modify storage zx:sweep record.hand set value "weapon.offhand"
tag @s remove zx.sd_off
execute store result storage zx:sweep record.enhanced int 1 run scoreboard players get #sd_enh zx.meta
execute as @e[tag=zx.sd_hit] run function sweetdream:equipment/sword/sickle_dreams/sweep/collect
tag @e[tag=zx.sd_hit] remove zx.sd_hit
scoreboard players add #sweep_id zx.meta 1
scoreboard players operation @s zx.sd_id = #sweep_id zx.meta
execute store result storage zx:sweep record.id int 1 run scoreboard players get @s zx.sd_id
data modify storage zx:sweep record.slot set from entity @s SelectedItemSlot
data modify storage zx:sweep record.x set from entity @s Pos[0]
data modify storage zx:sweep record.y set from entity @s Pos[1]
data modify storage zx:sweep record.z set from entity @s Pos[2]
data modify storage zx:sweep record.yaw set from entity @s Rotation[0]
data modify storage zx:sweep record.dimension set from entity @s Dimension
scoreboard players add @s zx.sd_leave 0
execute store result storage zx:sweep record.leave int 1 run scoreboard players get @s zx.sd_leave
function sweetdream:equipment/sword/sickle_dreams/sweep/context
function sweetdream:equipment/sword/sickle_dreams/sweep/save with storage zx:sweep ctx
scoreboard players set @s zx.sd_t -1
tag @s add zx.sd_sweep

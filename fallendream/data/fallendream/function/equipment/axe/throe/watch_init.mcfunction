# 仅登记已获得易伤的准确目标；独立40刻观察原版/环境的实际损失。
function fallendream:lib/entity_id
data modify storage zx:work nh_snapshot set from entity @s
function fallendream:lib/entity_uuid/build
data modify storage zx:work pn_watch set from storage zx:work native_uuid
execute store result storage zx:work pn_watch.sid int 1 run scoreboard players get @s zx.sid
execute store result storage zx:work pn_watch.hp int 1 run data get entity @s Health 1000
scoreboard players set #pn_ab zx.meta 0
execute store result score #pn_ab zx.meta run data get entity @s AbsorptionAmount 1000
execute store result storage zx:work pn_watch.ab int 1 run scoreboard players get #pn_ab zx.meta
function fallendream:equipment/axe/throe/watch_bind with storage zx:work pn_watch

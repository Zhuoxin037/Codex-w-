# 每位施放者分别记录自己的血色丝线。
data modify storage zx:work nh_snapshot.UUID set from entity @s UUID
function fallendream:lib/entity_uuid/build
data modify storage zx:work ft_pass.node.uuid set from storage zx:work native_uuid.uuid
scoreboard players operation #ft_line_until zx.meta = #now manacore.meta
scoreboard players add #ft_line_until zx.meta 100
execute if score #ft_olx zx.meta matches 1 run scoreboard players add #ft_line_until zx.meta 100
execute store result storage zx:work ft_pass.node.until int 1 run scoreboard players get #ft_line_until zx.meta
function fallendream:equipment/staff/fate_thread/line_upsert with storage zx:work ft_pass.node
particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.0} ~ ~1 ~ 0.2 0.2 0.2 0.01 4 normal

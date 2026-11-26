$execute unless data storage zx:ft live."$(owner)" run return 0
$data modify storage zx:ft frames[-1].f.record set from storage zx:ft live."$(owner)"
data modify storage zx:ft frames[-1].f.anchor set from storage zx:ft frames[-1].f.record.anchor
scoreboard players set #ft_end1 zx.meta 0
scoreboard players set #ft_end2 zx.meta 0
execute store result score #ft_end1 zx.meta run data get storage zx:ft frames[-1].f.record.end1
execute store result score #ft_end2 zx.meta run data get storage zx:ft frames[-1].f.record.end2
execute if score #ft_end1 zx.meta <= #now manacore.meta run data modify storage zx:ft frames[-1].f.record.a set value []
execute if score #ft_end2 zx.meta <= #now manacore.meta run data modify storage zx:ft frames[-1].f.record.b set value []
$execute if data storage zx:ft frames[-1].f.record{mode:0} unless data storage zx:ft frames[-1].f.record{main:"$(source)"} run return 0
data modify storage zx:ft frames[-1].f.shixin set value 0b
$execute as $(source) if entity @s[tag=zx.status.shixin] run data modify storage zx:ft frames[-1].f.shixin set value 1b
execute if data storage zx:ft frames[-1].f.record{mode:0} unless data storage zx:ft frames[-1].f{shixin:1b} run return 0
execute if data storage zx:ft frames[-1].f.record{mode:0} if score @s zx.ft_got matches 6.. run return 0
# A node outside the link radius cannot start a transfer. A fatal hit may start the last one.
$data modify storage zx:ft frames[-1].f.node set value "$(source)"
function fallendream:equipment/staff/fate_thread/transmit_bounds with storage zx:ft frames[-1].f
execute unless data storage zx:ft frames[-1].f{in_range:1b} run return 0
$execute if data storage zx:ft frames[-1].f.record.a[{uuid:"$(source)"}] run data modify storage zx:ft frames[-1].f.a set value 1b
$execute if data storage zx:ft frames[-1].f.record.b[{uuid:"$(source)"}] run data modify storage zx:ft frames[-1].f.b set value 1b
execute unless data storage zx:ft frames[-1].f{a:1b} unless data storage zx:ft frames[-1].f{b:1b} run return 0
execute if data storage zx:ft frames[-1].f{a:1b} run data modify storage zx:ft frames[-1].f.queue set from storage zx:ft frames[-1].f.record.a
execute if data storage zx:ft frames[-1].f{b:1b} run data modify storage zx:ft frames[-1].f.queue append from storage zx:ft frames[-1].f.record.b[]
scoreboard players add @s zx.ft_got 1
scoreboard players set @s zx.ft_emitting 1
function fallendream:equipment/staff/fate_thread/transmit_loop
scoreboard players set @s zx.ft_emitting 0

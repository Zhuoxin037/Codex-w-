$data modify storage zx:ft frames[-1].f.queue set from storage zx:ft frames[-1].f.record.$(group)
scoreboard players set #ft_nodes zx.meta 0
execute store result score #ft_nodes zx.meta run data get storage zx:ft frames[-1].f.queue
scoreboard players operation #ft_nodes zx.meta *= #10 zx.meta
execute store result storage zx:ft frames[-1].f.fixed int 1 run scoreboard players get #ft_nodes zx.meta
scoreboard players set @s zx.ft_emitting 1
function fallendream:equipment/staff/fate_thread/tighten_loop
scoreboard players set @s zx.ft_emitting 0
$data modify storage zx:ft frames[-1].f.record.$(group) set value []

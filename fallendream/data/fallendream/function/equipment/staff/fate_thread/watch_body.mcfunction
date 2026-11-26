$execute unless data storage zx:ft live."$(owner)" run return run function fallendream:equipment/staff/fate_thread/watch_legacy
$data modify storage zx:ft frames[-1].f.record set from storage zx:ft live."$(owner)"
execute if data storage zx:ft frames[-1].f.record{mode:0} run function fallendream:equipment/staff/fate_thread/check_main with storage zx:ft frames[-1].f.record
execute if data storage zx:ft frames[-1].f{stop:1b} run return run function fallendream:equipment/staff/fate_thread/watch_end
data modify storage zx:ft frames[-1].f.queue set from storage zx:ft frames[-1].f.record.a
data modify storage zx:ft frames[-1].f.queue append from storage zx:ft frames[-1].f.record.b[]
function fallendream:equipment/staff/fate_thread/find_anchor
execute if data storage zx:ft frames[-1].f{anchor:""} run return run function fallendream:equipment/staff/fate_thread/watch_end
data modify storage zx:ft frames[-1].f.record.anchor set from storage zx:ft frames[-1].f.anchor
function fallendream:equipment/staff/fate_thread/prune_group {group:"a"}
function fallendream:equipment/staff/fate_thread/prune_group {group:"b"}
execute unless data storage zx:ft frames[-1].f.record.a[0] unless data storage zx:ft frames[-1].f.record.b[0] run return run function fallendream:equipment/staff/fate_thread/watch_end
execute if data storage zx:ft frames[-1].f.record{mode:1} unless data storage zx:ft frames[-1].f{any:1b} run return run function fallendream:equipment/staff/fate_thread/watch_end
scoreboard players set #ft_end1 zx.meta 0
execute store result score #ft_end1 zx.meta run data get storage zx:ft frames[-1].f.record.end1
execute if data storage zx:ft frames[-1].f.record{mode:0} if score #ft_end1 zx.meta <= #now manacore.meta run return run function fallendream:equipment/staff/fate_thread/watch_end
execute if data storage zx:ft frames[-1].f.record{mode:1} if score #ft_end1 zx.meta <= #now manacore.meta if data storage zx:ft frames[-1].f.record.a[0] run function fallendream:equipment/staff/fate_thread/expire_group {group:"a"}
scoreboard players set #ft_end2 zx.meta 0
execute store result score #ft_end2 zx.meta run data get storage zx:ft frames[-1].f.record.end2
execute if data storage zx:ft frames[-1].f.record{mode:1} if score #ft_end2 zx.meta <= #now manacore.meta if data storage zx:ft frames[-1].f.record.b[0] run function fallendream:equipment/staff/fate_thread/expire_group {group:"b"}
execute unless data storage zx:ft frames[-1].f.record.a[0] unless data storage zx:ft frames[-1].f.record.b[0] run return run function fallendream:equipment/staff/fate_thread/watch_end
$data modify storage zx:ft live."$(owner)" set from storage zx:ft frames[-1].f.record

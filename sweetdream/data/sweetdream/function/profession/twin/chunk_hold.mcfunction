$execute unless data storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)" run data modify storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)" set value {count:0,was:0b}
$execute store result score #jfrefs zx.meta run data get storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)".count
$execute if score #jfrefs zx.meta matches 0 in $(dim) store success storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)".was byte 1 run forceload query $(bx) $(bz)
$execute if score #jfrefs zx.meta matches 0 in $(dim) run forceload add $(bx) $(bz)
scoreboard players add #jfrefs zx.meta 1
$execute store result storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)".count int 1 run scoreboard players get #jfrefs zx.meta
$data modify storage zx:jobs p."$(uuid)".body.force set from storage zx:work jfchunk

$execute unless data storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)" run return 0
$execute store result score #jfrefs zx.meta run data get storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)".count
scoreboard players remove #jfrefs zx.meta 1
$execute store result storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)".count int 1 run scoreboard players get #jfrefs zx.meta
$execute if score #jfrefs zx.meta matches ..0 unless data storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)"{was:1b} in $(dim) run forceload remove $(bx) $(bz)
$execute if score #jfrefs zx.meta matches ..0 run data remove storage zx:job_chunks "$(dim)"."$(cx)"."$(cz)"
$data remove storage zx:jobs p."$(uuid)".body.force

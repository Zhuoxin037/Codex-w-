$data remove storage zx:jobs p."$(uuid)".twin.pos
$data remove storage zx:jobs p."$(uuid)".twin.dim
$execute in minecraft:overworld as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:overworld run kill @e[tag=zx.j_host_watch,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:the_nether run kill @e[tag=zx.j_host_watch,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:the_end run kill @e[tag=zx.j_host_watch,distance=0..,nbt={data:{owner:"$(uuid)"}}]

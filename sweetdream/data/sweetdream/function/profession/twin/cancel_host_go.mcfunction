$data remove storage zx:jobs p."$(uuid)".twin.pos
$execute in minecraft:overworld as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:the_nether as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:the_end as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host

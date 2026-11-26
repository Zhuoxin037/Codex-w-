$data remove storage zx:jobs p."$(uuid)"
$execute in minecraft:overworld as @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}] run function fallendream:profession/twin/despawn
$execute in minecraft:overworld as @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}] run function fallendream:profession/twin/despawn
$execute in minecraft:the_nether as @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}] run function fallendream:profession/twin/despawn
$execute in minecraft:the_nether as @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}] run function fallendream:profession/twin/despawn
$execute in minecraft:the_end as @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}] run function fallendream:profession/twin/despawn
$execute in minecraft:the_end as @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}] run function fallendream:profession/twin/despawn

$execute in minecraft:overworld run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]

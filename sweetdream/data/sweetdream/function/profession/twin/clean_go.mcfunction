$data remove storage zx:jobs p."$(uuid)"
$execute in minecraft:overworld run kill @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:overworld run kill @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}]

$execute in minecraft:overworld run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]

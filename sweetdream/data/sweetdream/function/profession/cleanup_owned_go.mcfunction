$execute if data storage zx:jobs p."$(uuid)".body.force run data modify storage zx:work jfchunk set from storage zx:jobs p."$(uuid)".body.force
$execute if data storage zx:jobs p."$(uuid)".body.force run function sweetdream:profession/twin/chunk_release with storage zx:work jfchunk
$execute in minecraft:overworld run kill @e[tag=zx.j_follower,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:overworld run kill @e[tag=zx.j_choice,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:overworld as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:overworld run kill @e[tag=zx.j_delayed,distance=0..,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_follower,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_choice,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:the_nether run kill @e[tag=zx.j_delayed,distance=0..,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_follower,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_choice,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s remove zx.j_host
$execute in minecraft:the_end run kill @e[tag=zx.j_delayed,distance=0..,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}]

$execute in minecraft:overworld run kill @e[tag=zx.j_host_watch,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_host_watch,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_host_watch,distance=0..,nbt={data:{owner:"$(uuid)"}}]

$execute in minecraft:overworld run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_nether run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$execute in minecraft:the_end run kill @e[tag=zx.j_guard_carrier,distance=0..,nbt={data:{owner:"$(uuid)"}}]

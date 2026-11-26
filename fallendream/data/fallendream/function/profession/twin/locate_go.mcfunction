scoreboard players set #jbodyfound zx.meta 0
# Clear only lookup tags; the persistent owner is a full UUID string.
execute in minecraft:overworld run tag @e[tag=zx.j_anchor,distance=0..] remove zx.j_anchor
execute in minecraft:overworld run tag @e[tag=zx.j_shadow,distance=0..] remove zx.j_shadow
$execute in minecraft:overworld as @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}] run tag @s add zx.j_anchor
$execute in minecraft:overworld as @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}] run tag @s add zx.j_shadow
execute in minecraft:the_nether run tag @e[tag=zx.j_anchor,distance=0..] remove zx.j_anchor
execute in minecraft:the_nether run tag @e[tag=zx.j_shadow,distance=0..] remove zx.j_shadow
$execute in minecraft:the_nether as @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}] run tag @s add zx.j_anchor
$execute in minecraft:the_nether as @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}] run tag @s add zx.j_shadow
execute in minecraft:the_end run tag @e[tag=zx.j_anchor,distance=0..] remove zx.j_anchor
execute in minecraft:the_end run tag @e[tag=zx.j_shadow,distance=0..] remove zx.j_shadow
$execute in minecraft:the_end as @e[tag=zx.j_body,distance=0..,nbt={data:{owner:"$(uuid)"}}] run tag @s add zx.j_anchor
$execute in minecraft:the_end as @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}] run tag @s add zx.j_shadow
execute in minecraft:overworld if entity @e[tag=zx.j_anchor,distance=0..] run scoreboard players set #jbodyfound zx.meta 1
execute in minecraft:the_nether if entity @e[tag=zx.j_anchor,distance=0..] run scoreboard players set #jbodyfound zx.meta 1
execute in minecraft:the_end if entity @e[tag=zx.j_anchor,distance=0..] run scoreboard players set #jbodyfound zx.meta 1
$execute if score @s zx.j_host_t matches 1.. in minecraft:overworld as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s add zx.j_shadow
$execute if score @s zx.j_host_t matches 1.. in minecraft:the_nether as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s add zx.j_shadow
$execute if score @s zx.j_host_t matches 1.. in minecraft:the_end as @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] run tag @s add zx.j_shadow

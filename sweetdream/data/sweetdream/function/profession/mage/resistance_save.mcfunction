$data remove storage zx:jobs p."$(uuid)".resistance
$data modify storage zx:jobs p."$(uuid)".resistance set from entity @s active_effects[{id:"minecraft:resistance"}]

$data modify storage zx:combat chains."$(chain)".x set from entity @s Pos[0]
$data modify storage zx:combat chains."$(chain)".y set from entity @s Pos[1]
$data modify storage zx:combat chains."$(chain)".z set from entity @s Pos[2]
$execute if dimension minecraft:overworld run data modify storage zx:combat chains."$(chain)".dimension set value "minecraft:overworld"
$execute if dimension minecraft:the_nether run data modify storage zx:combat chains."$(chain)".dimension set value "minecraft:the_nether"
$execute if dimension minecraft:the_end run data modify storage zx:combat chains."$(chain)".dimension set value "minecraft:the_end"

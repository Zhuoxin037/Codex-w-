$bossbar add fallendream:b_staff_$(id) {"text":"白蓝持杖者"}
$bossbar set fallendream:b_staff_$(id) max 600
$bossbar set fallendream:b_staff_$(id) color blue
$execute if dimension minecraft:overworld run data modify storage fallendream:b_staff bars append value {id:$(id),dim:"minecraft:overworld"}
$execute if dimension minecraft:the_nether run data modify storage fallendream:b_staff bars append value {id:$(id),dim:"minecraft:the_nether"}
$execute if dimension minecraft:the_end run data modify storage fallendream:b_staff bars append value {id:$(id),dim:"minecraft:the_end"}
$execute if dimension fallendream:rogue_preview run data modify storage fallendream:b_staff bars append value {id:$(id),dim:"fallendream:rogue_preview"}

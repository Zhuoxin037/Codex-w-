scoreboard players set #cic_released zx.meta 0
$execute as @e[tag=zx.s2_cicada,distance=0..,nbt={data:{owner:"$(owner)"}}] if score @s zx.s2_end > #now manacore.meta run scoreboard players add #cic_released zx.meta 1
$execute as @e[tag=zx.s2_cicada,distance=0..,nbt={data:{owner:"$(owner)"}}] at @s run function fallendream:equipment/armor/empty_cicada/explode

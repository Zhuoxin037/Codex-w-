# Exact previously settled extra-skill amount × 60%; no fresh attack-stat calculation.
function sweetdream:internal/bow/payload
data modify storage zx:work a.fixed set value 1b
function sweetdream:internal/damage/with_from with storage zx:work a
execute at @s run particle minecraft:soul ~ ~1 ~ 0.3 0.4 0.3 0.01 6 normal

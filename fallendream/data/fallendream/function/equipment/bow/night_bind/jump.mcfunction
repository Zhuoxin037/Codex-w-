# Exact previously settled extra-skill amount × 60%; no fresh attack-stat calculation.
function fallendream:internal/bow/payload
data modify storage zx:work a.fixed set value 1b
function fallendream:internal/attack/submit_extra
execute at @s run particle minecraft:soul ~ ~1 ~ 0.3 0.4 0.3 0.01 6 normal

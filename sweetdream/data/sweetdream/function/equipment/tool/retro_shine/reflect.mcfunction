# Second post_attack entry: @s is the real living attacker, including remote projectile owners.
execute unless data storage zx:work rt.num run return 0
execute unless entity @s[type=#sweetdream:living] run return 0
data modify storage zx:work a set from storage zx:work rt
data remove storage zx:work rt
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
execute at @s run particle minecraft:dust{color:[0.85,0.75,0.5],scale:1.1} ~ ~1 ~ 0.35 0.45 0.35 0.02 12 normal

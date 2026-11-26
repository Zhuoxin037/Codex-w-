execute if entity @s[type=minecraft:player] run return 0
execute if entity @s[tag=zx.j_body] run return run function fallendream:profession/twin/protect_sleep
data merge entity @s {Invulnerable:1b,Silent:1b}
# Also block ordinary creative-player attacks, which bypass the vanilla Invulnerable flag.
effect give @s minecraft:resistance infinite 4 true

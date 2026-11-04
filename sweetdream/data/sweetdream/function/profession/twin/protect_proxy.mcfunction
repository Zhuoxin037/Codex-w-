execute if entity @s[type=minecraft:player] run return 0
data merge entity @s {Invulnerable:1b,Silent:1b}
# Also block ordinary creative-player attacks, which bypass the vanilla Invulnerable flag.
effect give @s minecraft:resistance infinite 4 true

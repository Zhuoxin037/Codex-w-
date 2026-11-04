execute if entity @s[type=minecraft:player] run return 0
execute unless entity @s[tag=zx.j_body] unless entity @s[tag=zx.j_twin] run return 0
data merge entity @s {Silent:1b,Invulnerable:1b}
tag @s add zx.j_dispose
tag @s remove zx.j_body
tag @s remove zx.j_twin
tag @s remove zx.j_anchor
tag @s remove zx.j_shadow
execute if dimension minecraft:the_end run return run function sweetdream:profession/twin/despawn_overworld
function sweetdream:profession/twin/despawn_end

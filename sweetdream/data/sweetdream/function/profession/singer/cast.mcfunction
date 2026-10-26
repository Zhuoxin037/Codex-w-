# Freeze the caster's position; follower damage uses its owner's stats, not the triggering ally's.
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast
tag @s add zx.j_ally_cast
execute at @s as @e[tag=zx.j_follower,tag=!zx.j_return,distance=..3] at @s run function sweetdream:profession/singer/pulse
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast

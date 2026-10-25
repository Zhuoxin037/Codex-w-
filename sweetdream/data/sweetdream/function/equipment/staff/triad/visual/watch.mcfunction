# Keep active cast cleanup even after dropping the weapon; unrelated players exit before NBT.
execute unless entity @s[tag=zx.tv_cast] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["triad"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["triad"]}] run return 0
# Reuse one snapshot for death, selected slot and both idle-frame checks.
data remove storage zx:triad_watch player
data modify storage zx:triad_watch player set from entity @s
function sweetdream:equipment/staff/triad/visual/watch_active
data remove storage zx:triad_watch player

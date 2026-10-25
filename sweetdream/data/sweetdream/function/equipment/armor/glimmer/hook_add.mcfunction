# @calc: add — red is additive; white replaces red and is independent.
execute unless entity @s[type=minecraft:player] run return 0
function sweetdream:equipment/armor/glimmer/state
execute unless score #gl_mode zx.meta matches 1 run return 0
data modify storage zx:work put.pct set value 20
function sweetdream:lib/dmg_add_put_any

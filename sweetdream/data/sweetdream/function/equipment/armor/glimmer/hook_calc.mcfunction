# @calc: indep — only white grants an independent 30%.
execute unless entity @s[type=minecraft:player] run return 0
function sweetdream:equipment/armor/glimmer/state
execute unless score #gl_mode zx.meta matches 2 run return 0
scoreboard players set #glc zx.meta 0
execute store result score #glc zx.meta run data get storage manacore:out r.damage 1000
scoreboard players set #glk zx.meta 130
function manacore:internal/damage/mul_pct {src:"#glc",mul:"#glk",obj:"zx.meta"}
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta

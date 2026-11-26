# Re-running revenge memory does not replace a running vanilla target goal. Make that
# goal fail once, then restore the original follow range and let the revenge goal choose
# the already recorded original body. No health is removed by the 0-damage provocation.
execute if score @s zx.j_taunt_due > #now manacore.meta run return 0
scoreboard players operation @s zx.j_taunt_due = #now manacore.meta
scoreboard players add @s zx.j_taunt_due 40
attribute @s minecraft:follow_range modifier remove fallendream:body_taunt_reset
attribute @s minecraft:follow_range modifier add fallendream:body_taunt_reset -1 add_multiplied_total
scoreboard players set @s zx.j_taunt_wait 2
tag @s add zx.j_taunt_reset
damage @s 0 fallendream:sleep_provocation by @e[tag=zx.j_taunt_body,limit=1,distance=..24]

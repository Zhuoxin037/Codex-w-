function sweetdream:profession/mage/resistance_end
# Reset hooks run after the framework may already have replaced stats. Do not subtract
# old combat/stat ledgers here; only clear this owner's actors, storage, and item guards.
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work jt_reset.uuid set from storage zx:data self.uuid
execute store result storage zx:work jt_reset.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work jt_reset.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work jt_reset.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work jt_reset.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:profession/reset_actors_go with storage zx:work jt_reset
function sweetdream:profession/twin/unguard
attribute @s minecraft:max_absorption modifier remove sweetdream:prophecy_absorption
attribute @s minecraft:attack_damage modifier remove sweetdream:profession_berserker

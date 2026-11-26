function fallendream:lib/uuid
data modify storage zx:work nr_owner set value {owner:""}
data modify storage zx:work nr_owner.owner set from storage zx:data self.uuid
function fallendream:equipment/axe/no_return/clear_owned with storage zx:work nr_owner
scoreboard players set @s zx.nr_extra 0
scoreboard players add @s zx.nr_gen 1

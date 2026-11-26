function fallendream:lib/uuid
data modify storage zx:work s2_forget set value {owner:""}
data modify storage zx:work s2_forget.owner set from storage zx:data self.uuid
function fallendream:batch21/shield/forget_go with storage zx:work s2_forget
tag @s remove zx.s2_shield
scoreboard players set @s zx.s2_abs 0
scoreboard players set @s zx.s2_abs_next 0

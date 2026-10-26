# Only the invalid position resets; preserve this body's health and mana.
scoreboard players set @s zx.j_reborn 1
function sweetdream:profession/twin/return
scoreboard players set @s zx.j_reborn -1
function sweetdream:lib/uuid
data modify storage zx:work jt.uuid set from storage zx:data self.uuid
function sweetdream:profession/twin/reset_position with storage zx:work jt
tellraw @s {"text":"超过本我者 24 格，已强制返回。","color":"red"}

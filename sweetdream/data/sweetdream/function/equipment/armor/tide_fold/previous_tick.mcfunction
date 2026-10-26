execute unless score @s zx.tf_seen = #now manacore.meta run return run kill @s
execute store result storage zx:work tf_previous.sid int 1 run scoreboard players get @s zx.sid
function sweetdream:equipment/armor/tide_fold/previous_sync with storage zx:work tf_previous

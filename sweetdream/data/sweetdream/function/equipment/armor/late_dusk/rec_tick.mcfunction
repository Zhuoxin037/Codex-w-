# The record is closed before its extra damage; other open records may observe it.
execute if score @s zx.lr_end > #now manacore.meta run return 0
function sweetdream:equipment/armor/late_dusk/rec_finish with entity @s data.lr
kill @s

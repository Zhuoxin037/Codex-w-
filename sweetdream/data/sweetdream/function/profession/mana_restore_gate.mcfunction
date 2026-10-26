scoreboard players set #jrestore_value zx.meta 0
execute store result score #jrestore_value zx.meta run data get storage manacore:work a.value 1000
execute unless score #jrestore_value zx.meta matches 1.. run return 0
function sweetdream:profession/mana_restore_gate_go with storage manacore:work a

function sweetdream:profession/mage/tally
execute store result score #jpreview zx.meta run data get storage manacore:out r.bonus 1000
function sweetdream:profession/mage/regen_preview_go with storage manacore:work a
scoreboard players operation #jpreview zx.meta += #jregenmax zx.meta
execute store result storage manacore:out r.bonus double .001 run scoreboard players get #jpreview zx.meta

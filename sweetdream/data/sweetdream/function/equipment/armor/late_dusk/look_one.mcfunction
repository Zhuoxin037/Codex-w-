$scoreboard players operation #hud_ld zx.meta = @s $(o)
scoreboard players operation #hud_ld zx.meta -= #now manacore.meta
scoreboard players add #hud_ld zx.meta 19
scoreboard players operation #hud_ld zx.meta /= #20 zx.meta
execute store result storage zx:work hud_ld.seconds int 1 run scoreboard players get #hud_ld zx.meta
function sweetdream:equipment/armor/late_dusk/look_value with storage zx:work hud_ld

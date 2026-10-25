function sweetdream:lib/look/separator
scoreboard players operation #hud_ld zx.meta = @s zx.ld_t
scoreboard players operation #hud_ld zx.meta -= #now manacore.meta
scoreboard players add #hud_ld zx.meta 19
scoreboard players operation #hud_ld zx.meta /= #20 zx.meta
data modify storage zx:look xline append value {text:"回光余时 ",color:"dark_purple"}
data modify storage zx:look xline append value {score:{name:"#hud_ld",objective:"zx.meta"},color:"light_purple"}
data modify storage zx:look xline append value {text:"s",color:"gray"}

scoreboard players operation #hud_gl zx.meta = @s zx.gl_wt
scoreboard players operation #hud_gl zx.meta -= #now manacore.meta
scoreboard players add #hud_gl zx.meta 19
scoreboard players operation #hud_gl zx.meta /= #20 zx.meta
data modify storage zx:look xline append value {text:"白光 ",color:"white"}
data modify storage zx:look xline append value {score:{name:"#hud_gl",objective:"zx.meta"},color:"white"}
data modify storage zx:look xline append value {text:"s",color:"gray"}

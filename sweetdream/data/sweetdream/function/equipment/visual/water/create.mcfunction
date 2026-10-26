function sweetdream:lib/entity_id
$data modify storage zx:work water_fx set value {model:"$(model)",sx:$(sx),sy:$(sy),sz:$(sz),kind:"$(kind)",dy:0.0,yaw:0.0,link:0,ticks:0}
execute store result storage zx:work water_fx.link int 1 run scoreboard players get @s zx.sid
$execute store result storage zx:work water_fx.ticks int 1 run scoreboard players get @s $(life_obj)
execute store result storage zx:work water_fx.yaw float 1 run data get entity @s Rotation[0]
execute if data storage zx:work water_fx{kind:"wave"} run scoreboard players add #water_phase zx.meta 1
scoreboard players set #water_phases zx.meta 32
scoreboard players operation #water_phase zx.meta %= #water_phases zx.meta
execute if data storage zx:work water_fx{kind:"wave"} store result storage zx:work water_fx.dy float 0.001 run scoreboard players get #water_phase zx.meta
function sweetdream:equipment/visual/water/spawn with storage zx:work water_fx

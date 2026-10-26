# @s is the damaged target; each proc creates its own five-second instance.
execute unless entity @s[tag=zx.lr_watch] run function sweetdream:equipment/armor/late_dusk/watch_init
function sweetdream:equipment/armor/late_dusk/watch
scoreboard players add @s zx.lr_live 1
data modify storage zx:work lr_open set from storage zx:work ld
execute store result storage zx:work lr_open.tid int 1 run scoreboard players get @s zx.sid
execute store result storage zx:work lr_open.base int 1 run scoreboard players get @s zx.lr_sum
scoreboard players operation #lr_deadline zx.meta = #now manacore.meta
scoreboard players add #lr_deadline zx.meta 100
execute store result storage zx:work lr_open.end int 1 run scoreboard players get #lr_deadline zx.meta
function sweetdream:equipment/armor/late_dusk/rec_spawn with storage zx:work lr_open
data modify storage zx:work fz set value {target:"@s",ticks:40}
function sweetdream:lib/timestop with storage zx:work fz
particle minecraft:dust{color:[0.45,0.35,0.6],scale:1.5} ~ ~1 ~ 0.5 0.6 0.5 0.02 20

tag @e[tag=sd.bs.source,distance=0..] remove sd.bs.source
execute store result storage fallendream:b_staff effect.owner int 1 run scoreboard players get @s bs.owner
function fallendream:boss/b_staff/fx/owner with storage fallendream:b_staff effect
execute unless entity @e[tag=sd.bs.source,distance=0..,limit=1] run return run kill @s
execute if entity @e[tag=sd.bs.source,tag=zx.stop,distance=0..,limit=1] run return run function fallendream:boss/b_staff/fx/clear_source
scoreboard players operation #clock bs.clock = @e[tag=sd.bs.source,distance=0..,limit=1] bs.clock
execute if score @s bs.born = #clock bs.clock run return run function fallendream:boss/b_staff/fx/clear_source
scoreboard players operation #owner bs.id = @s bs.owner
scoreboard players operation #cast bs.cast = @s bs.cast
scoreboard players add @s bs.fage 1
execute if score @s bs.fage > @s bs.life run return run function fallendream:boss/b_staff/fx/end
execute if score @s bs.kind matches 1 run function fallendream:boss/b_staff/fx/bolt_tick
execute if score @s bs.kind matches 2 run function fallendream:boss/b_staff/fx/mark_tick
execute if score @s bs.kind matches 3 run function fallendream:boss/b_staff/fx/ring_tick
execute if score @s bs.kind matches 4 run function fallendream:boss/b_staff/fx/repel_tick
execute if score @s bs.kind matches 5 run function fallendream:boss/b_staff/fx/sigil_tick
function fallendream:boss/b_staff/fx/clear_source

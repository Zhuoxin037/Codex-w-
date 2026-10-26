function sweetdream:lib/uuid
data modify storage zx:work jfchunk set value {uuid:"",dim:"minecraft:overworld",bx:0,bz:0,cx:0,cz:0}
data modify storage zx:work jfchunk.uuid set from storage zx:data self.uuid
data modify storage zx:work jfchunk.dim set from entity @s Dimension
execute store result score #jbx zx.meta run data get entity @s Pos[0]
execute store result score #jbz zx.meta run data get entity @s Pos[2]
execute store result storage zx:work jfchunk.bx int 1 run scoreboard players get #jbx zx.meta
execute store result storage zx:work jfchunk.bz int 1 run scoreboard players get #jbz zx.meta
execute if score #jbx zx.meta matches ..-1 run scoreboard players remove #jbx zx.meta 15
execute if score #jbz zx.meta matches ..-1 run scoreboard players remove #jbz zx.meta 15
scoreboard players set #j16 zx.meta 16
scoreboard players operation #jbx zx.meta /= #j16 zx.meta
scoreboard players operation #jbz zx.meta /= #j16 zx.meta
execute store result storage zx:work jfchunk.cx int 1 run scoreboard players get #jbx zx.meta
execute store result storage zx:work jfchunk.cz int 1 run scoreboard players get #jbz zx.meta
function sweetdream:profession/twin/chunk_hold with storage zx:work jfchunk

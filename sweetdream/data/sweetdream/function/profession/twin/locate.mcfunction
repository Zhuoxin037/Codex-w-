function sweetdream:lib/uuid
data modify storage zx:work jt.uuid set from storage zx:data self.uuid
function sweetdream:profession/twin/locate_go with storage zx:work jt

execute store result storage zx:work jt.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work jt.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work jt.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work jt.u3 int 1 run scoreboard players get @s manacore.u3

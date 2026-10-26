function sweetdream:lib/uuid
data modify storage zx:work jt.uuid set from storage zx:data self.uuid
data modify storage zx:work jt.u0 set from entity @s UUID[0]
data modify storage zx:work jt.u1 set from entity @s UUID[1]
data modify storage zx:work jt.u2 set from entity @s UUID[2]
data modify storage zx:work jt.u3 set from entity @s UUID[3]
function sweetdream:profession/twin/record_go with storage zx:work jt

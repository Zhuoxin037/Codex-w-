data modify storage zx:fbcombat target set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:fbcombat target.u0 set from entity @s UUID[0]
data modify storage zx:fbcombat target.u1 set from entity @s UUID[1]
data modify storage zx:fbcombat target.u2 set from entity @s UUID[2]
data modify storage zx:fbcombat target.u3 set from entity @s UUID[3]
data modify storage zx:fbcombat record.targets append from storage zx:fbcombat target

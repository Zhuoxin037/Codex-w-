# 目标快照只存 UUID，不留下跨 tick 的共享目标标签。
data modify storage zx:sweep target set value {}
data modify storage zx:sweep target.u0 set from entity @s UUID[0]
data modify storage zx:sweep target.u1 set from entity @s UUID[1]
data modify storage zx:sweep target.u2 set from entity @s UUID[2]
data modify storage zx:sweep target.u3 set from entity @s UUID[3]
data modify storage zx:sweep record.targets append from storage zx:sweep target

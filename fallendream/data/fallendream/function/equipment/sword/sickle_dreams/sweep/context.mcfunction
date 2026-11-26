# 完整 UUID 四整数拼键，不依赖前置包旧的短 UUID。
data modify storage zx:sweep ctx set value {}
data modify storage zx:sweep ctx.u0 set from entity @s UUID[0]
data modify storage zx:sweep ctx.u1 set from entity @s UUID[1]
data modify storage zx:sweep ctx.u2 set from entity @s UUID[2]
data modify storage zx:sweep ctx.u3 set from entity @s UUID[3]

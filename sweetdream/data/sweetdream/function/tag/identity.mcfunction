# 用实体 UUID 的全部四个整数配对，不依赖易丢失/碰撞的全局借号器。
# 始终覆盖全部参数，上一只生物的临时信息不会泄漏到下一只。
data modify storage zx:tag owner set value {}
data modify storage zx:tag owner.u0 set from entity @s UUID[0]
data modify storage zx:tag owner.u1 set from entity @s UUID[1]
data modify storage zx:tag owner.u2 set from entity @s UUID[2]
data modify storage zx:tag owner.u3 set from entity @s UUID[3]

# 仍在同一肩侧位置；攻击期间朝向本次目标的真实落点，目标死亡后也不失去方向。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
$execute on vehicle at @a[tag=zx.ub,distance=0..,limit=1] rotated as @a[tag=zx.ub,distance=0..,limit=1] rotated ~ 0 positioned ^-1.05 ^1.35 ^-0.35 facing $(x) $(y) $(z) rotated ~ 0 run tp @s ~ ~ ~ ~ 0

# 首版位置：玩家右侧1.05格、后方0.35格、高1.35格。只取水平朝向，抬头不把灯带飞。
# 本地X为左，所以右侧写负值。物品显示实体直接使用玩家朝向，不额外翻转180度。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute on vehicle at @a[tag=zx.ub,distance=0..,limit=1] rotated as @a[tag=zx.ub,distance=0..,limit=1] rotated ~ 0 positioned ^-1.05 ^1.35 ^-0.35 run tp @s ~ ~ ~ ~ 0

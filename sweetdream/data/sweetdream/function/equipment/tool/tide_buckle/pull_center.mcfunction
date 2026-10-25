# 每个被消费对象各结算一次；执行者是当前圆心，宏参数是消费玩家 UUID。
# 固定的 limit=1 圆心选择器也避免 facing entity 拒绝范围选择器。
tag @e[tag=zx.tb_center,distance=0..] remove zx.tb_center
tag @e[tag=zx.tb_pull,distance=0..] remove zx.tb_pull
tag @s add zx.tb_center
execute at @s run tag @e[type=!#sweetdream:no_damage,tag=!zx.tb_center,distance=..2,sort=nearest,limit=2] add zx.tb_pull
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute if entity @e[tag=zx.tb_pull,distance=0..] as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/tool/tide_buckle/pull_go
tag @e[tag=zx.tb_pull,distance=0..] remove zx.tb_pull
tag @s remove zx.tb_center

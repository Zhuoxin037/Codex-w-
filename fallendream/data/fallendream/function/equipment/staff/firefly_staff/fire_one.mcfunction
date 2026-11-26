data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run kill @s
execute rotated as @a[tag=zx.ub,distance=0..,limit=1] run tp @s ~ ~ ~ ~ ~
scoreboard players set @s zx.ff_age 0
# 被 mark_homing 挑中的那 5 个走追踪路径(见 fly); 其余沿主人朝向直线飞
execute if data entity @s data.target run tag @s add zx.ff_homing
tag @s remove zx.ff_idle
tag @s add zx.ff_fly

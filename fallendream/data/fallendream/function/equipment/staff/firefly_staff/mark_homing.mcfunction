# 沿准星测试生物碰撞箱，给本次施法中最多 5 个属于自己的萤火记录目标 UUID。
data remove storage zx:work firefly.target
scoreboard players set #ff_ray zx.meta 0
execute anchored eyes positioned ^ ^ ^0.25 anchored feet run function fallendream:equipment/staff/firefly_staff/aim_step
execute unless data storage zx:work firefly.target run return 0
function fallendream:equipment/staff/firefly_staff/set_homing with storage zx:work firefly

$execute unless entity $(vx_uuid) run return 0

# uuid(读快捷栏技能 / 查冷却都要)
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 数"快捷栏里正在冷却的其它主动技能"
function fallendream:equipment/sword/crescent/count

# 分档
execute if score #cr_n zx.meta matches 0 run return 0
execute if score #cr_n zx.meta matches 1 run function fallendream:equipment/sword/crescent/pass1
execute if score #cr_n zx.meta matches 2 run function fallendream:equipment/sword/crescent/pass2
execute if score #cr_n zx.meta matches 3.. run function fallendream:equipment/sword/crescent/pass3

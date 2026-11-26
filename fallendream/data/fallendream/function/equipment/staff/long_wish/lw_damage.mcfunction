# 没有可附着的生物: 对被消耗者(zx.lw_cons)造成 领域主人最大魔力值 x0.1 伤害。
# 取"被消耗者所在领域"的 owner UUID 四 int 反查主人, 由主人身份算伤害与归属。
data modify storage zx:work lwfb set from entity @e[tag=zx.lw_active,limit=1] data.zx
function fallendream:lib/find_by with storage zx:work lwfb
execute as @a[tag=zx.mc_by,limit=1] run function fallendream:equipment/staff/long_wish/lw_damage_go
tag @a remove zx.mc_by

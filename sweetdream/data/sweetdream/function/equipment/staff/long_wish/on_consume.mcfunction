# 长愿领域·标签转移叶子(宏, with storage zx:work mc)。
# mc = {target, mark, by, src, ok, done}; 由主对话在 lib/on_consume 里挂 hook。
# 在领域内的生物被消耗了通用标签 -> 把该标签附到领域内随机另一个没有该标签的生物
# (本次消耗只转移一次); 优先选普攻命中记下的 zx.lw_prio; 没有可附着目标就伤害被消耗者。
tag @e[tag=zx.lw_cons] remove zx.lw_cons
tag @e[tag=zx.lw_active] remove zx.lw_active
tag @e[tag=zx.lw_cand] remove zx.lw_cand
tag @e[tag=zx.lw_dest] remove zx.lw_dest
$execute as $(target) at @s if entity @e[tag=zx.lw_field,distance=..8] run tag @s add zx.lw_cons
execute unless entity @e[tag=zx.lw_cons,limit=1] run return 0
execute as @e[tag=zx.lw_field] at @s if entity @e[tag=zx.lw_cons,distance=..8] run tag @s add zx.lw_active
tag @e[tag=zx.lw_cand] remove zx.lw_cand
$execute at @e[tag=zx.lw_active] run tag @e[type=!#sweetdream:no_damage,distance=..8,tag=!zx.status.$(mark),tag=!zx.lw_cons] add zx.lw_cand
tag @e[tag=zx.lw_dest] remove zx.lw_dest
execute as @e[tag=zx.lw_cand,tag=zx.lw_prio,limit=1] run tag @s add zx.lw_dest
execute unless entity @e[tag=zx.lw_dest,limit=1] as @e[tag=zx.lw_cand,sort=random,limit=1] run tag @s add zx.lw_dest
execute if entity @e[tag=zx.lw_dest,limit=1] run function sweetdream:equipment/staff/long_wish/lw_transfer
execute unless entity @e[tag=zx.lw_dest,limit=1] run function sweetdream:equipment/staff/long_wish/lw_damage
tag @e[tag=zx.lw_cons] remove zx.lw_cons
tag @e[tag=zx.lw_active] remove zx.lw_active
tag @e[tag=zx.lw_cand] remove zx.lw_cand
tag @e[tag=zx.lw_dest] remove zx.lw_dest

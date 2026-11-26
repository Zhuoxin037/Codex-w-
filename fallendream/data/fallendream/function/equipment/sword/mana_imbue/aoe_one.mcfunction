# ============================================================
# fallendream:equipment/sword/mana_imbue/aoe_one —— 对一只被波及的生物打 80%
# ------------------------------------------------------------
# 【执行者】被波及的生物   【基准】zx:work ima_base（aoe 抄的一份快照）
# 【★ 不接收宏参数★】由 aoe 的 `execute as @e[...]` 逐个送进来；宏参数走
#   zx:work a 的话，第一只改完 a 后面几只就缺参了（见 aoe 头注释）。
# ============================================================

execute unless entity @s run return 0

# 80% = num × 8 / 10（千分单位保留小数，最后统一乘 0.001 还原）
scoreboard players set #ima zx.meta 0
execute store result score #ima zx.meta run data get storage zx:work ima_base.num 1000
# ★ R05: ×1000 定点再乘 #8 会越过 int32 上界（回绕成负数、不报错）
#   动态上限 = 2147483647 ÷ 8，再钳住；除法前的 matches 1.. 守卫不能省
scoreboard players set #ima_cap zx.meta 2147483647
execute if score #8 zx.meta matches 1.. run scoreboard players operation #ima_cap zx.meta /= #8 zx.meta
execute if score #ima zx.meta > #ima_cap zx.meta run scoreboard players operation #ima zx.meta = #ima_cap zx.meta
scoreboard players operation #ima zx.meta *= #8 zx.meta
scoreboard players set #ima_10 zx.meta 10
scoreboard players operation #ima zx.meta /= #ima_10 zx.meta
execute if score #ima zx.meta matches ..0 run return 0

# 从基准复原投递入参，只把目标换成这一只
data modify storage zx:work a set from storage zx:work ima_base
data modify storage zx:work a.target set value "@s"
execute store result storage zx:work a.num double 0.001 run scoreboard players get #ima zx.meta
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra

# ============================================================
# fallendream:equipment/staff/magic_theory/count —— 数"同一个生物吃了几发导轨"
# ------------------------------------------------------------
# 【执行者】被命中的生物; 宏参数 {owner,target}
# 【存储】zx:b21 rails.<主人uuid>.<生物uuid> = 该生物这一轮吃到的发数
# 【★ 「每个目标在同一轮导轨中最多触发一次三发追加爆炸」】
#   超限会补回导轨, 一轮里可能打出 4 发以上 ⇒ 同一个生物会第二次凑到 3。
#   所以追加爆炸一触发就把这格记成 99(哨兵), 之后直接 return, 不再累加。
#   基础版永远只有 3 发导轨, 走不到第二条, 行为与以前完全一致。
# 【★ 为什么把 99 写回存储而不是只改分数】分数是临时量, 下一发会重新 data get;
#   不写回就等于没记住"这个目标已经爆过了"。
# ============================================================
scoreboard players set #s2_rail_hits zx.meta 0
$execute store result score #s2_rail_hits zx.meta run data get storage zx:b21 rails."$(owner)"."$(target)"
execute if score #s2_rail_hits zx.meta matches 99.. run return 0
scoreboard players add #s2_rail_hits zx.meta 1
$execute store result storage zx:b21 rails."$(owner)"."$(target)" int 1 run scoreboard players get #s2_rail_hits zx.meta
execute unless score #s2_rail_hits zx.meta matches 3 run return 0
# 到 3 发: 先记哨兵(超限才需要, 基础版 3 发封顶, 记不记都一样), 再结算爆炸
execute if score #s2_rail_ol zx.meta matches 1 run scoreboard players set #s2_rail_hits zx.meta 99
$execute if score #s2_rail_ol zx.meta matches 1 run execute store result storage zx:b21 rails."$(owner)"."$(target)" int 1 run scoreboard players get #s2_rail_hits zx.meta
data modify storage zx:work ub set from storage zx:work s2_rail
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] positioned ~ ~ ~ run function fallendream:equipment/staff/magic_theory/burst

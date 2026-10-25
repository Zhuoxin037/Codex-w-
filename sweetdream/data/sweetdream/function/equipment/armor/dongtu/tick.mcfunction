# ============================================================
# sweetdream:equipment/armor/dongtu/tick —— 冻土（钻石靴 · 被动）每刻状态机
# ------------------------------------------------------------
# 【执行者】玩家（core/tick 每刻 as @a 调一次）
# 【机制】站定 1.5 秒不动 → 获得「冻土」：抗性提升Ⅰ + 每秒回复 3% 最大生命，
#         最多 6 秒（共 18%），移动立即中断，中断那刻起 20 秒冷却。
# 【为什么不需要"受伤后"这个前提】冻土看的是"站住"，不是"被打"——
#   这是它和驻足（受伤后才等 1.5 秒）唯一的行为差别。
# 【第一行判装备】不穿就不产生负载。
# ============================================================
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["dongtu"]}] run return 0
scoreboard players add @s zx.dng_cd 0

# ① 站定 1.5 秒且不在冷却 → 启动
execute unless score @s zx.dng_on matches 1 if score @s zx.st_n matches 30.. if score @s zx.dng_cd <= #now manacore.meta run function sweetdream:equipment/armor/dongtu/start

# ② 生效中但站不住 → 中断
execute if score @s zx.dng_on matches 1 if score @s zx.st_n matches ..29 run function sweetdream:equipment/armor/dongtu/stop

# ============================================================
# fallendream:equipment/armor/smoke_step/move_tick —— 超限·烟履: 迅捷期间累计移动
# ------------------------------------------------------------
# 【谁调用它】batch21/player_tick（每刻，`if score @s zx.ss_spd_end matches 1..` 门控）
# 【执行者】玩家（@s）
# 【文案(lore 逐字)】…在本件给予的迅捷持续期间累计移动 4 格后，在 3 秒内下一次普通近战
#   命中附有「流火」的生物后可额外触发一次上述效果。
# 【★ 为什么要"每 5 刻采样一次" ★】读玩家坐标 = `data modify … from entity @s Pos`
#   = 一次玩家整份 NBT 序列化（约 10ms）。每刻读一次, 3 秒窗口 = 60 次 ≈ 0.6 秒预算,
#   多几个人就顶不住。这里每 5 刻（0.25 秒）采样一次: 3 秒共 12 次, 位移误差可忽略。
# 【★ 距离口径 ★】每段采样取 |dx|+|dy|+|dz|（三维曼哈顿, 单位 0.01 格）。
#   斜向直线会比真实位移偏大（最多 1.73 倍）, 也就是"斜着跑更容易攒满" ——
#   按"宁可早一点给"取舍, 记在这里。
# 【★ 基线谁写 ★】victim_body ⑧ 开窗时就把 zx.ss_px/py/pz 写成开窗那一刻的坐标,
#   所以本函数不需要"第一次跑"的判断。
# 【★ 攒满后 ★】zx.ss_extra = #now+60（"3 秒内"），并把 zx.ss_move 归零,
#   避免同一个 4 格反复兑。额外一次由 hit.mcfunction ② 放行、victim_body ⑩ 消费。
# ============================================================

# ⓪ -1 常数（取绝对值用；包内 frost_step/tick 同款写法，但不共用假计分项）
scoreboard players set #ss_m1 zx.meta -1

# ① 窗口过了 -> 停（采样器与到期刻都归零, 否则 player_tick 会一直白调这个函数）
execute unless score @s zx.ss_spd_end > #now manacore.meta run scoreboard players set @s zx.ss_smp 0
execute unless score @s zx.ss_spd_end > #now manacore.meta run scoreboard players set @s zx.ss_spd_end 0
execute unless score @s zx.ss_spd_end > #now manacore.meta run return 0

# ② 每 5 刻采样一次
scoreboard players add @s zx.ss_smp 1
execute unless score @s zx.ss_smp matches 5.. run return 0
scoreboard players set @s zx.ss_smp 0

# ③ 取当前坐标（一次 NBT 读）
data modify storage zx:work ss.pos set from entity @s Pos
scoreboard players set #ss_nx zx.meta 0
execute store result score #ss_nx zx.meta run data get storage zx:work ss.pos[0] 100
scoreboard players set #ss_ny zx.meta 0
execute store result score #ss_ny zx.meta run data get storage zx:work ss.pos[1] 100
scoreboard players set #ss_nz zx.meta 0
execute store result score #ss_nz zx.meta run data get storage zx:work ss.pos[2] 100

# ④ 本段位移 = |dx| + |dy| + |dz|
scoreboard players operation #ss_dx zx.meta = #ss_nx zx.meta
scoreboard players operation #ss_dx zx.meta -= @s zx.ss_px
execute if score #ss_dx zx.meta matches ..-1 run scoreboard players operation #ss_dx zx.meta *= #ss_m1 zx.meta
scoreboard players operation #ss_dy zx.meta = #ss_ny zx.meta
scoreboard players operation #ss_dy zx.meta -= @s zx.ss_py
execute if score #ss_dy zx.meta matches ..-1 run scoreboard players operation #ss_dy zx.meta *= #ss_m1 zx.meta
scoreboard players operation #ss_dz zx.meta = #ss_nz zx.meta
scoreboard players operation #ss_dz zx.meta -= @s zx.ss_pz
execute if score #ss_dz zx.meta matches ..-1 run scoreboard players operation #ss_dz zx.meta *= #ss_m1 zx.meta
scoreboard players operation #ss_sum zx.meta = #ss_dx zx.meta
scoreboard players operation #ss_sum zx.meta += #ss_dy zx.meta
scoreboard players operation #ss_sum zx.meta += #ss_dz zx.meta

# ⑤ 累加 + 把采样点推进
scoreboard players add @s zx.ss_move 0
scoreboard players operation @s zx.ss_move += #ss_sum zx.meta
scoreboard players operation @s zx.ss_px = #ss_nx zx.meta
scoreboard players operation @s zx.ss_py = #ss_ny zx.meta
scoreboard players operation @s zx.ss_pz = #ss_nz zx.meta

# ⑥ 满 4 格（400 = 4 × 100）-> 攒一次"额外触发"，3 秒内有效
execute if score @s zx.ss_move matches 400.. run scoreboard players operation @s zx.ss_extra = #now manacore.meta
execute if score @s zx.ss_move matches 400.. run scoreboard players add @s zx.ss_extra 60
execute if score @s zx.ss_move matches 400.. run scoreboard players set @s zx.ss_move 0
execute if score @s zx.ss_move matches 0 if score @s zx.ss_extra > #now manacore.meta run particle minecraft:smoke ~ ~0.2 ~ 0.3 0.1 0.3 0.02 6 normal

# ============================================================
# sweetdream:equipment/armor/frost_step/tick —— 步霜：累计移动 8 格触发一次
# ------------------------------------------------------------
# 【谁调用它】core/tick：execute as @a at @s run function sweetdream:equipment/armor/frost_step/tick
# 【执行者】全体玩家 @a（每刻）
# 【技能原文（逐字）】
#   最大魔力值 +60。自身每累计移动 8 格，使自身 4 格内的生物获得 2 秒缓慢 I。
# 【★ 为什么不用 lib/step 的 zx.sm_chk ★】读过 step.mcfunction：那是雨迹/踏灰
#   "技能施放后有没有真的位移"的整套状态机（含补点自递归、窗口续期），绑死在
#   "刚放过位移技能的玩家"上，不是通用移动累计器。这里照 lvshuang/tick 的坐标
#   采样口径自己逐刻累加，独立不互相踩。
# 【读法】"累计移动 8 格" = 逐刻累加**水平移动路程**（单位 0.01 格，8 格 = 800），
#   到 800 触发一次并把累加器清零重计；只算水平，跳跃/下落不累计；
#   一次大跨度位移只结算一次。
#   ★ 位移长度用 8 方向近似 max(|dx|,|dz|)+0.414×min(|dx|,|dz|)，误差 <4%，
#     避免曼哈顿把斜向 45° 的 8 格缩水成 5.7 格。
# ============================================================

# ① 穿着门控（盔甲被动，函数体第一行）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["frost_step"]}] run return 0

# ② 本刻坐标（×100 整数，锁水平两轴）
execute store result score #fs_x zx.meta run data get entity @s Pos[0] 100
execute store result score #fs_z zx.meta run data get entity @s Pos[2] 100

# ③ 首次采样只建立"上一刻"基准（用临时标记判，避免 set 之后又判 0 的死分支）
scoreboard players add @s zx.fs_i 0
scoreboard players add @s zx.fs_px 0
scoreboard players add @s zx.fs_pz 0
scoreboard players set #fs_first zx.meta 0
execute if score @s zx.fs_i matches 0 run scoreboard players set #fs_first zx.meta 1
execute if score #fs_first zx.meta matches 1 run scoreboard players operation @s zx.fs_px = #fs_x zx.meta
execute if score #fs_first zx.meta matches 1 run scoreboard players operation @s zx.fs_pz = #fs_z zx.meta
execute if score #fs_first zx.meta matches 1 run scoreboard players set @s zx.fs_i 1
execute if score #fs_first zx.meta matches 1 run return 0

# ④ 本刻水平位移 dx / dz（×100）
scoreboard players operation #fs_dx zx.meta = #fs_x zx.meta
scoreboard players operation #fs_dx zx.meta -= @s zx.fs_px
scoreboard players operation #fs_dz zx.meta = #fs_z zx.meta
scoreboard players operation #fs_dz zx.meta -= @s zx.fs_pz

# ⑤ 把"上一刻"推进到本刻（无论触发与否都要记账，下一刻的差值才对）
scoreboard players operation @s zx.fs_px = #fs_x zx.meta
scoreboard players operation @s zx.fs_pz = #fs_z zx.meta

# ⑥ 位移长度 ≈ max(|dx|,|dz|) + 0.414 × min(|dx|,|dz|)
scoreboard players set #fs_neg zx.meta -1
scoreboard players set #fs_414 zx.meta 414
scoreboard players operation #fs_a zx.meta = #fs_dx zx.meta
execute if score #fs_a zx.meta matches ..-1 run scoreboard players operation #fs_a zx.meta *= #fs_neg zx.meta
scoreboard players operation #fs_b zx.meta = #fs_dz zx.meta
execute if score #fs_b zx.meta matches ..-1 run scoreboard players operation #fs_b zx.meta *= #fs_neg zx.meta
scoreboard players operation #fs_mx zx.meta = #fs_a zx.meta
scoreboard players operation #fs_mn zx.meta = #fs_b zx.meta
execute if score #fs_b zx.meta > #fs_a zx.meta run scoreboard players operation #fs_mx zx.meta = #fs_b zx.meta
execute if score #fs_b zx.meta > #fs_a zx.meta run scoreboard players operation #fs_mn zx.meta = #fs_a zx.meta
scoreboard players operation #fs_step zx.meta = #fs_mn zx.meta
scoreboard players operation #fs_step zx.meta *= #fs_414 zx.meta
scoreboard players operation #fs_step zx.meta /= #1000 zx.meta
scoreboard players operation #fs_step zx.meta += #fs_mx zx.meta

# ⑦ 累加路程；到 8 格（800）触发一次并清零（清零在 trigger 里）
scoreboard players add @s zx.fs_acc 0
scoreboard players operation @s zx.fs_acc += #fs_step zx.meta
execute if score @s zx.fs_acc matches 800.. run function sweetdream:equipment/armor/frost_step/trigger

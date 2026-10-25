# ============================================================
# sweetdream:lib/still —— "站定不动"检测（驻足 / 冻土 共用）
# ------------------------------------------------------------
# 【执行者】玩家
# 【谁调】core/tick，每 2 刻一次（`#now % 2 == 0`）
# 【产物】
#   zx.st_n  = 连续静止的刻数（上限 200；移动立刻归 0）
#   zx.st_x / zx.st_z = 上一次采样的水平坐标（×100，整数）
#   zx.st_i  = 是否已建立过基准（1 = 有了）
# 【为什么只比水平】跳一下、上下台阶都不该算"移动"；冻结/缓降也不该打断。
#   竖直位移在包内的既有判定里一律不算走位（雨迹的 lib/step 也是 x/z）。
# 【容差 4 = 0.04 格】浮点抖动 + 摄像机微移不会误判成"动了"。
# 【为什么不写实体 NBT】全部落计分项，不碰 chunk（见 2026-10-20 法球延迟那条）。
# 【★★ 2026-10-20 第四次卡顿修复: 先判装备, 不穿就一条命令退出 ★★】
#   本函数 core/tick 每 2 刻对**每个玩家**跑一次, 下面两条 `data get entity @s Pos`
#   每次都是**全量玩家 NBT 序列化**。spark 实测一次 ≈ 10 ms（详见
#   internal/damage/who 头注释）⇒ 光这一处就吃掉半条 tick 预算。
#   而它的产物 zx.st_n 只有驻足 / 冻土两双靴子在用（消费点见 RULES 的站定条目）
#   ⇒ 没穿这两双就直接 return, 绝大多数玩家每刻 0 次 NBT。
# ============================================================
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["zhuzu"]}] unless items entity @s armor.feet *[minecraft:custom_data~{zx:["dongtu"]}] run return 0

execute store result score #st_x zx.meta run data get entity @s Pos[0] 100
execute store result score #st_z zx.meta run data get entity @s Pos[2] 100

scoreboard players add @s zx.st_i 0
scoreboard players add @s zx.st_x 0
scoreboard players add @s zx.st_z 0
scoreboard players add @s zx.st_n 0

# 第一次跑：只建立基准
#   ★ 判据用临时标记 #st_first，不再"set st_i 1 之后又判 st_i = 0" ——
#     那是典型的"改排在判前面"，后面那条永远不成立（check 规则 58）。
scoreboard players set #st_first zx.meta 0
execute if score @s zx.st_i matches 0 run scoreboard players set #st_first zx.meta 1
execute if score #st_first zx.meta matches 1 run scoreboard players operation @s zx.st_x = #st_x zx.meta
execute if score #st_first zx.meta matches 1 run scoreboard players operation @s zx.st_z = #st_z zx.meta
execute if score #st_first zx.meta matches 1 run scoreboard players set @s zx.st_i 1
execute if score #st_first zx.meta matches 1 run return 0

scoreboard players operation #st_dx zx.meta = #st_x zx.meta
scoreboard players operation #st_dx zx.meta -= @s zx.st_x
scoreboard players operation #st_dz zx.meta = #st_z zx.meta
scoreboard players operation #st_dz zx.meta -= @s zx.st_z

# 任一轴超过 0.04 格 = 动过 → 静止计数清零
execute if score #st_dx zx.meta matches 4.. run scoreboard players set @s zx.st_n 0
execute if score #st_dx zx.meta matches ..-4 run scoreboard players set @s zx.st_n 0
execute if score #st_dz zx.meta matches 4.. run scoreboard players set @s zx.st_n 0
execute if score #st_dz zx.meta matches ..-4 run scoreboard players set @s zx.st_n 0

# 两轴都在容差内 = 静止 → +2 刻（本函数每 2 刻跑一次）
execute if score #st_dx zx.meta matches -3..3 if score #st_dz zx.meta matches -3..3 run scoreboard players add @s zx.st_n 2
execute if score @s zx.st_n matches 202.. run scoreboard players set @s zx.st_n 200

scoreboard players operation @s zx.st_x = #st_x zx.meta
scoreboard players operation @s zx.st_z = #st_z zx.meta

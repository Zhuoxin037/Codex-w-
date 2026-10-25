# ============================================================
# sweetdream:debug/heal_probe_double —— lib/heal 重入自检：**同一刻连调两次**
# ------------------------------------------------------------
# 【为什么需要它】2026-10-19 修的那个 bug（连治两次直接满血）只在"上一轮的临时
#   上限还没撤"时暴露 —— 单次探针 debug/heal_probe 永远测不出来。必须**同一刻**
#   连调两次；绯缝(5% 上限) 与殓丝(30% 上限) 在同一击里就是这种情况。
# 【用法】
#   ① 先把自己弄掉血，留够空间（例：/damage @s 15）；
#   ② /function sweetdream:debug/heal_probe_double        （默认每次 4 点、共两次）
#      想改单次点数：先 /scoreboard players set #hp_req zx.meta 5 再跑；
#   ③ **不用敲第二条** —— 2 刻后自动打 [后] 与两个 d 值。
# 【怎么读】
#   · [后] ≈ [前] + 2×点数          -> 正常（例：上限 20、当前 5、每次 5 ⇒ 应到 15）
#   · [后] = 上限（血条满）          -> 又回到"重入直接满血"的老 bug
#   · d2 = 0 而 d1 ≠ 0              -> 第二次没算出自己的增量（同一个 bug 的早期形态）
#   · [后] = [前] + 点数（只加了一次）-> 基点取错，第二次被当成重复
# 【只读】不动装备/标签/冷却，只写 zx.meta 上的 #hp_* / #heal_* 假玩家。
#   ★ 一次只测一个人（读数写在同一组假玩家上，多人同测会互相覆盖）。
# ============================================================

# ---- ① 单次点数：#hp_req 没设过就默认 4 ----
scoreboard players add #hp_req zx.meta 0
execute if score #hp_req zx.meta matches ..0 run scoreboard players set #hp_req zx.meta 4

tellraw @s [{"text":"===== lib/heal 重入自检（同一刻两次）=====","color":"gold"}]

# ---- ② 前读数（×1000，看得见小数）+ 上限 ----
scoreboard players set #hp_before2 zx.meta 0
execute store result score #hp_before2 zx.meta run data get entity @s Health 1000
scoreboard players set #hp_max2 zx.meta 0
execute store result score #hp_max2 zx.meta run attribute @s minecraft:max_health get

# ---- ③ 连调两次：两次之间**不许**出现任何 tick 边界 ----
#   ★ 这就是复现条件：第一发药水还没到 tickEffects，第二发就要开始算量了。
scoreboard players operation #heal_pt zx.meta = #hp_req zx.meta
function sweetdream:lib/heal
scoreboard players operation #heal_d1 zx.meta = #heal_d zx.meta

scoreboard players operation #heal_pt zx.meta = #hp_req zx.meta
function sweetdream:lib/heal

tellraw @s [{"text":" [前] ","color":"gray"},{"score":{"name":"#hp_before2","objective":"zx.meta"},"color":"aqua"},{"text":" (×1000)    上限 ","color":"gray"},{"score":{"name":"#hp_max2","objective":"zx.meta"},"color":"aqua"},{"text":" 点    每次 ","color":"gray"},{"score":{"name":"#hp_req","objective":"zx.meta"},"color":"aqua"},{"text":" 点 × 2 次","color":"gray"}]
tellraw @s [{"text":" [内部] d1=","color":"gray"},{"score":{"name":"#heal_d1","objective":"zx.meta"},"color":"light_purple"},{"text":"  d2=","color":"gray"},{"score":{"name":"#heal_d","objective":"zx.meta"},"color":"light_purple"},{"text":"  base=","color":"gray"},{"score":{"name":"#heal_base","objective":"zx.meta"},"color":"light_purple"},{"text":"  ★ d1 应 = −点数；d2 应 = −点数（不是 0）","color":"dark_gray"}]

# ---- ④ 药水要等下一拍 tickEffects，2 刻后自动读 ----
tellraw @s [{"text":" 药水在**下一拍**生效 —— 2 刻后自动打 [后] 与差值…","color":"dark_gray"}]
tag @s add zx.hp_probe2
schedule function sweetdream:debug/heal_probe_double_read 2t replace

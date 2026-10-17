# ============================================================
# sweetdream:equipment/armor/rain_trace/dot_tick —— 水迹点每刻一跳（执行者 = 水迹点实体）
# ------------------------------------------------------------
# 【谁调用它】core/tick：三维度各一句
#   `execute in <维度> as @e[tag=zx.rt_dot,distance=0..] at @s run …`
# 【水迹点是什么】minecraft:item_display（2026-10-17 从 marker 换过来，带水洼模型）。
#   它和 marker 一样在 `#sweetdream:no_damage` 类型标签里 ⇒ 下面那些
#   `type=!#sweetdream:no_damage` 的扫描不会把它自己当成生物（换载体时特意确认过）。
# 【每刻干什么】
#   ① 寿命 -1（出生时 100 刻 = 5 秒），到点自毁
#   ② 附近的生物：登记/刷新"在我这段水迹里"
#   ③ 停满 2 秒的生物：附「渊海」+ 吃一次伤害（pay）
#   ④ 刚落地那几刻溅一下水花（之后只靠模型贴图本身，不再每刻喷粒子）
# 【★ 为什么停在 2 秒要靠水迹点侧算 ★】生物身上只记"首次进入刻"和"容忍到期刻"
#   两个数字；判定和兑现都在点这一侧（伤害值/归属存在它的 NBT 里）。
#   这样同一只生物被两个水迹点覆盖也不会重复打两份伤害（pay 里兑现完把它置 2）。
# ============================================================

# ① 寿命
scoreboard players remove @s zx.rt_life 1
execute if score @s zx.rt_life matches ..0 run return run kill @s

# ② 附近生物登记（1.6 格 = 水迹半径；点的间隔 ≤ 1 格，刚好连成带）
execute as @e[type=!#sweetdream:no_damage,distance=..1.6] run function sweetdream:equipment/armor/rain_trace/touch

# ③ 停满 2 秒的兑现
execute if entity @e[type=!#sweetdream:no_damage,distance=..1.6,scores={zx.rt_on=1}] run function sweetdream:equipment/armor/rain_trace/pay

# ④ 表现：只在"刚撒下"的 4 刻里溅水花
#   ★ 为什么不再每刻喷 ★ 改成逐刻撒点后，无息一次位移就有约 20 个点；
#   每点每刻 2 个粒子 = 每刻 40 个，屏幕会被水花糊住。现在每个点只在自己
#   落地那一刻冒一下，剩下的由贴图负责 —— 既省性能又不会盖住模型。
execute if score @s zx.rt_life matches 96.. run particle minecraft:splash ~ ~0.05 ~ 0.45 0.01 0.45 0 4 normal
execute if score @s zx.rt_life matches 96.. run particle minecraft:falling_water ~ ~0.1 ~ 0.5 0.02 0.5 0 3 normal

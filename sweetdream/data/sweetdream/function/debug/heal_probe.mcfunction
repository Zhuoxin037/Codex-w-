# ============================================================
# sweetdream:debug/heal_probe —— lib/heal（回血原语）单件自检 · 发药水那一步
# ------------------------------------------------------------
# 【用法】
#   ① 先把自己弄掉血（例：/damage @s 19）；
#   ② 跑：/function sweetdream:debug/heal_probe        （默认恢复 4 点）
#      想试别的点数：先 /scoreboard players set #hp_req zx.meta 6 再跑。
#   ③ **不用再敲第二条命令** —— 本件会 schedule 自己在 2 刻后打结果
#      （见 debug/heal_probe_read）。聊天栏会先出 [前]，2 刻后再出 [后 → 差值]。
# 【★ 为什么要分两拍（2026-10-16 改）★】
#   `instant_health` 是在**实体的 tickEffects()** 里才真正治疗的，而本函数是玩家在
#   聊天栏手动执行的 —— 那一刻早于 tickEffects()。所以**同一次执行内**读 Health
#   一定读到"还没治"的旧值。原来那种"调用完立刻读"的探针只会误报"没生效"。
# 【读聊天栏】
#   · 后 − 前 ≈ 要求点数          -> 正常
#   · 后 = 上限（血条满）          -> 天花板没撑到药水生效（时序又坏了）
#   · 前后一模一样                -> 药水没被应用，把 [内部] 整行念给我
# 【只读】不动装备/标签/冷却，只写 zx.meta 上的 #hp_* / #heal_* 假玩家。
#   ★ 一次只测一个人（读数写在同一组假玩家上，多人同测会互相覆盖）。
# ============================================================

# ---- ① 入参：#hp_req 没设过就默认 4（add 0 会把它建出来，0/负数不管） ----
scoreboard players add #hp_req zx.meta 0
execute if score #hp_req zx.meta matches ..0 run scoreboard players set #hp_req zx.meta 4

tellraw @s [{"text":"===== lib/heal 自检 =====","color":"gold"}]

# ---- ② 前读数（×1000，看得见小数） ----
scoreboard players set #hp_before zx.meta 0
execute store result score #hp_before zx.meta run data get entity @s Health 1000
scoreboard players set #hp_max zx.meta 0
execute store result score #hp_max zx.meta run attribute @s minecraft:max_health get

# ---- ③ 调用（lib/heal 会把 #heal_cur / #heal_cap / #heal_new / #heal_d 留在 zx.meta 上）----
scoreboard players operation #heal_pt zx.meta = #hp_req zx.meta
function sweetdream:lib/heal
scoreboard players add #hp_runs zx.meta 1

tellraw @s [{"text":" [前] ","color":"gray"},{"score":{"name":"#hp_before","objective":"zx.meta"},"color":"aqua"},{"text":" (×1000)    上限 ","color":"gray"},{"score":{"name":"#hp_max","objective":"zx.meta"},"color":"aqua"},{"text":" 点    要求恢复 ","color":"gray"},{"score":{"name":"#hp_req","objective":"zx.meta"},"color":"aqua"},{"text":" 点","color":"gray"}]
tellraw @s [{"text":" [内部] cap=","color":"gray"},{"score":{"name":"#heal_cap","objective":"zx.meta"},"color":"light_purple"},{"text":" new=","color":"gray"},{"score":{"name":"#heal_new","objective":"zx.meta"},"color":"light_purple"},{"text":" d=","color":"gray"},{"score":{"name":"#heal_d","objective":"zx.meta"},"color":"light_purple"},{"text":"   （d 必须 ≤ 0 的整数；d=0 表示血已顶到上限）","color":"dark_gray"}]

# ---- ④ 药水要等下一拍的 tickEffects 才生效 -> 两刻后自动读结果 ----
tellraw @s [{"text":" 药水在**下一拍**生效 —— 2 刻后自动打 [后] 与差值…","color":"dark_gray"}]
tag @s add zx.hp_probe
schedule function sweetdream:debug/heal_probe_read 2t replace

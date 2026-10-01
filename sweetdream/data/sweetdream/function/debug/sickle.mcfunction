# ============================================================
# sweetdream:debug/sickle —— 引梦镰 专用自检(只读)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/sickle
# 【看什么】
#   · 强化锁还剩几秒 —— 不是 0 就说明你刚触发过强化, 8 秒内只会打基础版
#   · 8 格内有多少只带「噬心」的怪 —— 0 说明附近没有能吃强化条件的目标
# 【为什么要它】强化的判定是"圈里的怪里有没有带噬心的":
#   圈的位置不对(离得远 / 不在准星方向), 即使旁边有噬心怪也不会触发。
# ============================================================

tellraw @s [{"text":"===== 引梦镰 自检 =====","color":"gold","bold":true}]

scoreboard players operation #sd_lock_dbg zx.meta = @s zx.sd_lock
tellraw @s [{"text":"强化锁剩余秒 ","color":"gray"},{"score":{"name":"#sd_lock_dbg","objective":"zx.meta"},"color":"white"},{"text":"   (0 = 可以触发强化)","color":"dark_gray"}]

scoreboard players set #sd_dbg zx.meta 0
execute as @e[type=!#sweetdream:no_damage,distance=..8] if entity @s[tag=zx.status.shixin] run scoreboard players add #sd_dbg zx.meta 1
tellraw @s [{"text":"8 格内带噬心的生物 ","color":"gray"},{"score":{"name":"#sd_dbg","objective":"zx.meta"},"color":"light_purple"},{"text":"   只","color":"dark_gray"}]

tellraw @s [{"text":"提示: 强化的判定范围是「前方 2*3」, 所以要站在噬心怪面前、准星对着它再右键","color":"gold","italic":true}]

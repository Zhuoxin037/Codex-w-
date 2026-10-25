# ============================================================
# sweetdream:equipment/armor/lvshuang/frost_tick —— 霜场每秒判定（执行者 = marker）
# ------------------------------------------------------------
# 【谁调】lib/second 每秒一次（三维度各一行）
# 【敌人】半径 1.2 内 → 缓慢Ⅱ 2 秒（是"2 秒"，不是刷新 1 秒：设计原话如此，
#   而且霜本身存在 5 秒，留一点尾巴可以接受 —— 和铁蒺藜的"离开立刻消失"不同要求）
# 【自己】那个"自己"= 站在霜上的玩家（霜是踩出来的，不会离自己太远）
# 【不消耗霜】踩上去只给效果，霜不消失
# ============================================================
effect give @e[type=!#sweetdream:no_damage,distance=..1.2] minecraft:slowness 2 1 true
effect give @a[gamemode=!spectator,distance=..1.2] minecraft:speed 2 0 true

particle minecraft:snowflake ~ ~0.05 ~ 0.35 0.02 0.35 0.005 5 normal
particle minecraft:dust{color:[0.78,0.88,0.95],scale:0.8} ~ ~0.05 ~ 0.3 0.02 0.3 0.003 4 normal

scoreboard players remove @s zx.lsh_ft 1
execute if score @s zx.lsh_ft matches ..0 run function sweetdream:equipment/armor/lvshuang/frost_end

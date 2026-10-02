# ============================================================
# sweetdream:debug/fix_noai —— 抢救"永久 NoAI"的生物
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/fix_noai
# 【什么时候需要它】修 lib/timestop 的重入 bug 之前, 被"时停两次"污染过备份的
#   生物会带着 NoAI:1b 永远解不开。那份污染数据已经随解除一起 reset 掉了,
#   扫描线再也认不出它们 —— 只能这样手工放开。
# 【它做什么】把**当前维度**、你 32 格内、满足下面全部条件的生物恢复成 NoAI:0b:
#   · NoAI 显式为 1b
#   · 没有 zx.stop 标签  <- 正在正常时停的**不碰**(那些会自己解开)
#   · 不是玩家, 也不是 debug/tag_test 召唤的测试猪
# 【⚠️ 会误伤什么】你自己用 /summon ... {NoAI:1b} 摆的展示用生物, 如果落在
#   32 格内也会被放开。跑之前先把它们挪远, 或者跑完再手动 /data modify 设回去。
# 【为什么要连 zx.noai_bak / zx.ts_end 一起清】这两个是"时停账本",
#   留着脏值的话下一次时停会按旧账还原。
# ============================================================

tag @e[tag=zx.fix_noai] remove zx.fix_noai
execute at @s positioned ~-32 ~-32 ~-32 as @e[type=!player,dx=64.0,dy=64.0,dz=64.0,tag=!zx.stop,tag=!zx.tag_test,nbt={NoAI:1b}] run tag @s add zx.fix_noai

execute store result score #dbg_n zx.meta if entity @e[tag=zx.fix_noai]
execute as @e[tag=zx.fix_noai] run data modify entity @s NoAI set value 0b
execute as @e[tag=zx.fix_noai] run scoreboard players reset @s zx.noai_bak
execute as @e[tag=zx.fix_noai] run scoreboard players reset @s zx.ts_end

tellraw @s [{"text":"已放开 ","color":"green"},{"score":{"name":"#dbg_n","objective":"zx.meta"},"color":"white"},{"text":" 只卡住的生物(只处理当前维度、32 格内)","color":"green"}]
tellraw @s [{"text":"手工确认: /data get entity @e[type=zombie,limit=1] NoAI   应为 0b","color":"gray"}]

tag @e[tag=zx.fix_noai] remove zx.fix_noai

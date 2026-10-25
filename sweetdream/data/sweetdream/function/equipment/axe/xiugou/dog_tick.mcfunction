# ============================================================
# sweetdream:equipment/axe/xiugou/dog_tick —— 锈犬每秒结算（执行者 = marker）
# ------------------------------------------------------------
# 【谁调】lib/second 每秒一次（三维度各一行）
# 【顺序】先看还能不能咬（n <= 9）→ 咬 → 秒数 -1 → 到 0 收
# 【为什么每秒只咬一次】10 秒 × 1.0 倍基础攻击力的名义总伤是设计里的定值（10-20 定稿），
#   换成每刻咬会把总伤抬到 200 倍。
# ============================================================
execute if entity @s[tag=zx.xg_ol] if score @s zx.xg_n matches ..9 run function sweetdream:equipment/axe/xiugou/ol_bite
execute unless entity @s[tag=zx.xg_ol] if score @s zx.xg_n matches ..9 run function sweetdream:equipment/axe/xiugou/bite
scoreboard players remove @s zx.xg_ft 1
execute if score @s zx.xg_ft matches ..0 run function sweetdream:equipment/axe/xiugou/dog_end
execute at @s run particle minecraft:dust{color:[0.62,0.42,0.28],scale:0.7} ~ ~0.2 ~ 0.25 0.2 0.25 0.01 8 normal

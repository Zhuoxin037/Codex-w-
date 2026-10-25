# ============================================================
# sweetdream:equipment/sword/yebu/ol_stack —— 超限·曳步: 把 缓慢Ⅲ 往上叠 3 秒(上限 12 秒)
# ------------------------------------------------------------
# 【谁调用它】yebu/ol_slow ①(已经在缓慢里), 执行者 = 被命中的生物
# 【算法】新到期 = max(现在, zx.yb3) + 60，再夹到 现在+240(=12 秒) 以内
#   · 用 max(现在, 旧到期) 而不是"旧到期+60": 旧 Ⅲ 已经过期(但 Ⅰ 还在)时,
#     叠加起点应该是"现在" —— 否则第一发 Ⅲ 会立刻过期、只闪一下。
# 【时长换算】到期刻 → 秒 = (新到期 - 现在) / 20。因为到期刻永远是 现在+60/120/180/240,
#   除完必然是 3/6/9/12 —— 所以下面用四条 matches 精确给时长, 不写宏。
# 【★ 4 条 matches 而不是一条范围 ★】effect give 的时长必须字面量; 写成
#   `matches 3..5` 会同时命中两条 -> 后一条覆盖前一条, 时长随机。所以只写精确值。
# 【移速惩罚的时机】叠完之后总时长 > 10 秒(= 12 秒这一档) 才触发, 且每生物仅一次。
# ============================================================
scoreboard players operation #yb_new zx.meta = @s zx.yb3
execute if score #yb_new zx.meta < #yb_now zx.meta run scoreboard players operation #yb_new zx.meta = #yb_now zx.meta
scoreboard players add #yb_new zx.meta 60

scoreboard players operation #yb_cap zx.meta = #yb_now zx.meta
scoreboard players add #yb_cap zx.meta 240
execute if score #yb_new zx.meta > #yb_cap zx.meta run scoreboard players operation #yb_new zx.meta = #yb_cap zx.meta

scoreboard players operation #yb_sec zx.meta = #yb_new zx.meta
scoreboard players operation #yb_sec zx.meta -= #yb_now zx.meta
scoreboard players operation #yb_sec zx.meta /= #20 zx.meta

execute if score #yb_sec zx.meta matches 3 run effect give @s minecraft:slowness 3 2 true
execute if score #yb_sec zx.meta matches 6 run effect give @s minecraft:slowness 6 2 true
execute if score #yb_sec zx.meta matches 9 run effect give @s minecraft:slowness 9 2 true
execute if score #yb_sec zx.meta matches 12 run effect give @s minecraft:slowness 12 2 true

scoreboard players operation @s zx.yb = #yb_new zx.meta
scoreboard players operation @s zx.yb3 = #yb_new zx.meta
execute at @s run particle minecraft:dust{color:[0.42,0.5,0.62],scale:1.1} ~ ~0.45 ~ 0.45 0.5 0.45 0.005 12 normal

# 缓慢Ⅲ 总时长 > 10 秒 -> 移速 -50%, 5 秒, 每个生物仅一次
scoreboard players operation #yb_len zx.meta = #yb_new zx.meta
scoreboard players operation #yb_len zx.meta -= #yb_now zx.meta
execute if score #yb_len zx.meta matches 201.. if score @s zx.ybm matches 0 run function sweetdream:equipment/sword/yebu/ol_bind

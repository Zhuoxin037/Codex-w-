function sweetdream:equipment/staff/burst_bank/can_move
execute if score #bb_mv zx.meta matches 0 run scoreboard players set @s zx.bb_left 0
execute if score @s zx.bb_left matches ..0 run return 0
execute if score #bb_mv zx.meta matches 1 positioned ^ ^ ^0.5 run tp @s ~ ~ ~
execute if score #bb_mv zx.meta matches 2 positioned ^ ^1 ^0.5 run tp @s ~ ~ ~
# 名单只在这个同步子步里临时使用；持久去重按施放者UUID分开。
tag @e[tag=zx.bb_new,distance=..4] remove zx.bb_new
$execute at @s positioned ~-0.35 ~ ~-0.35 run tag @e[type=!#sweetdream:no_damage,distance=..0.8,tag=!zx.bb_path_$(uuid)] add zx.bb_new
$execute at @s positioned ~0.35 ~0.35 ~0.35 run tag @e[type=!#sweetdream:no_damage,distance=..0.8,tag=!zx.bb_path_$(uuid)] add zx.bb_new
execute at @s as @e[tag=zx.bb_new,distance=..4] at @s run function sweetdream:equipment/staff/burst_bank/path_dmg with storage zx:work bb
tag @e[tag=zx.bb_new,distance=..4] remove zx.bb_new
scoreboard players remove @s zx.bb_left 1
scoreboard players add @s zx.bb_run 1

# ★ 超限：水流痕迹（批 K8）★
#   【为什么每 4 个子步一个点】同刻跑 4 个子步 = 前进 2 格，正好两格一个点；
#     点距再密只是多几个 marker，判定半径 1.5 格已经能把整条路铺满。
#   【为什么用 marker 而不是"起点 + yaw + 长度"】路径会被撞停/绕行截断，
#     按真实落点撒点，天然就是"真正走过的地方"（坑 187 的同一口径）。
#   【★ 标记只带 tag 不带 NBT ★】每条每秒的判定都从施法者身上现取参数
#     （见 wet_own），marker 上写 NBT 只会让 chunk 变脏。
scoreboard players operation #bb_mod zx.meta = @s zx.bb_run
scoreboard players operation #bb_mod zx.meta %= #4 zx.meta
execute if data storage zx:work bb{ol:1} if score #bb_mod zx.meta matches 0 run function sweetdream:equipment/staff/burst_bank/wet_drop with storage zx:work bb

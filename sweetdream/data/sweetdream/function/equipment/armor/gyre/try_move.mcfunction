# ============================================================
# sweetdream:equipment/armor/gyre/try_move —— 走一段弧（执行位置 = 该段落点 marker）
# ------------------------------------------------------------
# 【谁调用它】arc ③（执行者 = 玩家，执行位置 = zx.gyr_w1/w2/w3 之一）
# 【通行的判据】脚（~ ~ ~）与头（~ ~1 ~）两格都必须落在 `#minecraft:replaceable`
#   里 —— 只判脚会让人半个身子卡进方块，只判头会掉进坑。
# 【遇到障碍即停】不可通行时把 zx.gyr_st 置 **99**（哨兵值）。
#   ★ 旧版置 1，但 1 现在是"过程中的第 1 刻"，会把状态机搅乱 ⇒ 必须用 99。
# 【★ 状态区间 1..6 = 过程中（2026-10-17 编号整体 +1）★】
#   0 = 未激活、7 = 收尾、99 = 撞墙。下面每条都判 1..6 —— 撞墙置 99 之后同一函数里
#   剩下的 tp / 伤害 / 音效就全部跳过（"遇到障碍即停"）。
# 【★ 为什么"沿途 30 点"写在这一层 ★】文案是"移动过程中碰到的生物" ——
#   每段落点 1.5 格内的生物就是"碰到"的近似（三段连起来覆盖整条弧线）。
# ============================================================

# ① 通行检查
execute unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set @s zx.gyr_st 99
execute if score @s zx.gyr_st matches 1..6 unless block ~ ~1 ~ #minecraft:replaceable run scoreboard players set @s zx.gyr_st 99

# ② 通行才传送（tp 用的是"当前位置"= 候选点，所以这句必须在 at marker 上下文里跑）
execute if score @s zx.gyr_st matches 1..6 run tp @s ~ ~ ~

# ③ 沿途 30 点固定伤害
execute if score @s zx.gyr_st matches 1..6 run function sweetdream:equipment/armor/gyre/path_hit

# ④ 落点水雾
execute if score @s zx.gyr_st matches 1..6 run particle minecraft:dust{color:[0.25,0.7,0.85],scale:1.1} ~ ~0.3 ~ 0.3 0.3 0.3 0.02 6 normal
execute if score @s zx.gyr_st matches 1..6 run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.4 1.6

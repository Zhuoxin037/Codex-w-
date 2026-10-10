# ============================================================
# sweetdream:equipment/axe/meteor/rock_tick —— 陨石每刻下落(执行者 = 陨石 item_display)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute in <维度> as @e[type=item_display,tag=zx.mt_rock] at @s run ...
# 【本函数在"每维度各跑一次"的链上】选择器都带位置参数(调用方 distance=0.. / 这里
#   的 tp 用 ~), 不出现裸 @e。
# 【每刻做什么】① 下降 1.75 格 ② 倒计时 -1 ③ 归零那刻炸开并 kill 自己。
# 【★ 用 `matches 1..` 提前 return ★】倒计时到 0 才执行落地段 —— 和 beam / 光柱那种
#   "扣完再判"同款。扣到 0 时立刻 kill 自己, 所以不存在"停在 0 还活着"的中间态。
# ============================================================

# ① 下降
tp @s ~ ~-1.75 ~

# ② 倒计时
scoreboard players remove @s zx.mt_rk 1
execute if score @s zx.mt_rk matches 1.. run return 0

# ③ 落地: 炸开(和 fall ④ 的爆炸粒子同款配色, 只是位置更贴地、更集中)
particle minecraft:explosion ~ ~0.25 ~ 0.35 0.2 0.35 0.0 3 normal
particle minecraft:large_smoke ~ ~0.25 ~ 0.8 0.4 0.8 0.06 18 normal
particle minecraft:flame ~ ~0.25 ~ 0.9 0.5 0.9 0.08 22 normal
particle minecraft:lava ~ ~0.25 ~ 0.7 0.3 0.7 0.0 14 normal
particle minecraft:block{block_state:"minecraft:magma_block"} ~ ~0.25 ~ 0.8 0.3 0.8 0.08 16 normal
playsound minecraft:entity.generic.explode block @a ~ ~ ~ 0.7 0.8
kill @s

# ============================================================
# sweetdream:equipment/sword/deepsea_echo/wave —— 每一波的入口(schedule 调用)
# ------------------------------------------------------------
# 【谁调用它】cast 里 schedule 出来的, 之后每波自己再 schedule 一次
# 【为什么先 execute as @a】schedule 出来的函数没有 @s;
#   靠玩家身上的 zx.de_run 标签把"还有链在跑的人"挑出来, 以他的身份推进。
# 【at @s】让后续的 @e 在"那个玩家所在的维度/位置"里找标记。
# ============================================================

execute as @a[tag=zx.de_run] at @s run function sweetdream:equipment/sword/deepsea_echo/wave_self

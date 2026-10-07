# ============================================================
# sweetdream:equipment/sword/aurora_dream/bell_sfx —— "飘渺的钟声"(执行者 = 施法者)
# ------------------------------------------------------------
# 【响给谁】施法者 24 格内的玩家。位置取施法者身上 —— 被时停的时间泡里在响钟。
# 【音色】★ 2026-10-04 改 ★ 原来用 block.bell.resonate + 紫水晶泛音, 玩家反馈
#   "根本就不是钟声"(resonate 是钟被敲后那种闷闷的共鸣尾音, 单独拎出来听很诡异)。
#   现在主音改成 **block.bell.use = 敲钟本音**(就是右键钟方块时那一声), 音调
#   略微调高 -> 空灵、飘渺; 再用一点紫水晶泛音(高八度)点缀, 音量压得很低。
# ============================================================

execute at @s run playsound minecraft:block.bell.use master @a[distance=..24] ~ ~ ~ 0.9 1.5
execute at @s run playsound minecraft:block.amethyst_block.chime master @a[distance=..24] ~ ~ ~ 0.35 2.0

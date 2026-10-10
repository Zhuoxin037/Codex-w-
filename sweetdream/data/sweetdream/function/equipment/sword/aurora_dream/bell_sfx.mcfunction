# ============================================================
# sweetdream:equipment/sword/aurora_dream/bell_sfx —— "飘渺的钟声"(执行者 = 施法者)
# ------------------------------------------------------------
# 【响给谁】施法者 24 格内的玩家。位置取施法者身上 —— 被时停的时间泡里在响钟。
# 【★ 2026-10-09 定版: 完全按玩家给的参考命令取值 ★】
#   玩家给的样板:
#     /playsound minecraft:block.bell.use block <玩家> <x> <y> <z> 0.1 0.3 0.1
#   ⇒ 音色 **block.bell.use**(敲钟本音, 就是右键钟方块那一声)
#      通道 **block** · 音量 **0.1** · 音调 **0.3**(极低 -> 闷而沉) · 最小音量 **0.1**。
#   ★ 原来那层"紫水晶泛音"(block.amethyst_block.chime) **已刻意去掉** ——
#     它是高频的"叮", 正是玩家反馈"太尖锐"的来源; 参考样板本身就是**单音色**,
#     跟着样板走才叫"参考这个钟声"。
#     (若要恢复泛音: 在下面加回一行
#        execute at @s run playsound minecraft:block.amethyst_block.chime block @a[distance=..24] ~ ~ ~ <vol> <pitch> <min>)
#   ★ playsound 的 volume 同时决定"可闻半径"(≈ volume × 16 格): 0.1 ≈ 1.6 格,
#     再配合 minVolume 0.1 —— 24 格内的玩家听到的都只是**极轻的一记闷钟**。
#     这就是"远处飘来的钟声"(飘渺)的听感。
# 【谁来驱动】aurora_dream/bell 在时停的整点各调本函数一次(时间轴 4 / 8 秒;
#   第 0 秒那声由 cast ⑦ 负责 —— 所以这里**不要**再加"起手一声")。
# ============================================================

# 主音: 敲钟本音(低音调 + 极低音量 + 最小音量 -> 飘渺)
execute at @s run playsound minecraft:block.bell.use block @a[distance=..24] ~ ~ ~ 0.1 0.3 0.1

# 极光与幻梦 · 钟声同步微亮
execute if entity @s[tag=zx.ad_cast] run scoreboard players set @s zx.ad_pulse 8
# 极光与幻梦 · 钟声同步微亮 / END

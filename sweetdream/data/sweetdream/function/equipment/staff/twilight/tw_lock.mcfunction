# ============================================================
# sweetdream:equipment/staff/twilight/tw_lock —— 给一个目标上"铠甲减半 + 抗性失效"
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑦ 步; 【执行者】目标生物
# 【护甲/韧性减半】attribute modifier(add_multiplied_base -0.5 = 基础值 ×0.5)。
#   同 id 重复 add 会静默失败(值不变), 所以重贴不用先 remove。
# 【抗性提升失效】立即清一次(之后每秒 tw_tick 再清)。
# 【倒计时】zx.tw_t = 8(秒)。
# ============================================================

attribute @s minecraft:armor modifier add sweetdream:tw_armor -0.5 add_multiplied_base
attribute @s minecraft:armor_toughness modifier add sweetdream:tw_tough -0.5 add_multiplied_base
effect clear @s minecraft:resistance
scoreboard players set @s zx.tw_t 8

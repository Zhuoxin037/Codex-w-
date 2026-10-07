# ============================================================
# sweetdream:equipment/armor/lethe_shore/begin —— 进入「残念」
# ------------------------------------------------------------
# 【谁调用它】hit(攻击次数够时)   【执行者】玩家   【位置】玩家处
# 【做什么】清计数 -> 打状态标签 -> 记 3 秒到期刻 -> 加速度 modifier -> 表现
# 【为什么用标签而不是只靠计分项】速度 modifier 的移除时机、每秒回魔、
#   "残念期间不计数"三处都要快速判"在不在残念里", 标签是最省的选择;
#   到期时刻用计分项(需要和 #now 比大小)。
# 【计时用绝对刻】zx.lt_end = #now + 60(3 秒) —— 和冷却同款, 跨维度/离线都准。
# ============================================================

# ① 清掉本次攒的计数(下次从 0 重新攒)
scoreboard players set @s zx.lt_n 0

# ② 打状态 + 记 3 秒到期刻
tag @s add zx.lethe
scoreboard players operation @s zx.lt_end = #now manacore.meta
scoreboard players add @s zx.lt_end 60

# ③ 基础速度翻倍
function sweetdream:equipment/armor/lethe_shore/apply_speed

# ④ 表现(冥河雾气上涌)
particle minecraft:soul ~ ~1 ~ 0.5 0.6 0.5 0.02 24 normal
particle minecraft:squid_ink ~ ~0.4 ~ 0.5 0.3 0.5 0.01 10 normal
playsound minecraft:block.soul_soil.break player @a ~ ~ ~ 0.7 0.8

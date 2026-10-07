# ============================================================
# sweetdream:equipment/staff/sail/whirl_end —— 旋风收场
# ------------------------------------------------------------
# 【谁调用它】whirl_tick 第 ③ 步; 【执行者/位置】旋风 marker
# ============================================================

tag @e[tag=zx.sl_area,distance=0..] remove zx.sl_area
particle minecraft:cloud ~ ~0.5 ~ 1.5 1.0 1.5 0.1 20 normal
particle minecraft:poof ~ ~0.5 ~ 0.6 0.6 0.6 0.05 12 normal
playsound minecraft:entity.breeze.death player @a ~ ~ ~ 0.7 1.2
kill @s

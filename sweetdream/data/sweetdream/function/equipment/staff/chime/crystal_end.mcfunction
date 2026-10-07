# ============================================================
# sweetdream:equipment/staff/chime/crystal_end —— 共鸣水晶: 8 秒自毁
# ------------------------------------------------------------
# 【谁调用它】chime/second(寿命到点; 执行者 = 水晶 marker)
# 【做什么】表现 + kill。没有伤害 / 没有收尾 —— 文案只写"8 秒后自毁"。
# ============================================================

particle minecraft:end_rod ~ ~0.6 ~ 0.3 0.4 0.3 0.06 24 normal
particle minecraft:enchant ~ ~0.6 ~ 0.4 0.4 0.4 0.4 20 normal
playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.8 1.4
kill @s

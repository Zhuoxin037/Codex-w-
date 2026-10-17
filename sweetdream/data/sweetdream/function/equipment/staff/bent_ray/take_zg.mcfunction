# ============================================================
# sweetdream:equipment/staff/bent_ray/take_zg —— 消除一只生物的「折光」
# ------------------------------------------------------------
# 【谁调用它】chain ⑨   【执行者】被消耗的那只生物
# 【做什么】摘标签 + 清到期刻(用 reset 而不是 set 0: 没有分数时 `if score` 恒不成立,
#   正好等价于"没有折光", 而且不会在生物身上留一堆 0)
# ============================================================

tag @s remove zx.br_g
scoreboard players reset @s zx.br_gl
particle minecraft:end_rod ~ ~1 ~ 0.3 0.3 0.3 0.15 10 normal
playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.8

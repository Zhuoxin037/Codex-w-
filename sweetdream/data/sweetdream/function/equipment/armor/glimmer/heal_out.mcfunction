# ============================================================
# sweetdream:equipment/armor/glimmer/heal_out —— 毫血累加器兑现（攒够 1 点才回）
# ------------------------------------------------------------
# 【执行者】玩家(@s)   【入参】zx.gl_hacc（毫血, ≥1000）
# 【做法】取整点 → 余数留在累加器里 → 调 lib/heal（入参 #heal_pt 必须是整数）
# 【★ 余数必须留 ★】每秒 1% × 20 血只有 200 毫(=0.2 点), 清余数就永远攒不满。
# ============================================================

scoreboard players set #gl_pt zx.meta 0
execute store result score #gl_pt zx.meta run scoreboard players get @s zx.gl_hacc
scoreboard players operation #gl_pt zx.meta /= #1000 zx.meta
scoreboard players operation @s zx.gl_hacc %= #1000 zx.meta
execute if score #gl_pt zx.meta matches 1.. run scoreboard players operation #heal_pt zx.meta = #gl_pt zx.meta
execute if score #gl_pt zx.meta matches 1.. run function sweetdream:lib/heal

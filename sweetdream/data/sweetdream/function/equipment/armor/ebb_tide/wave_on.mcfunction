# At most one increment per second, including overlapping waves.
execute if score @s zx.et_stack_t = #now manacore.meta run return 0
scoreboard players operation @s zx.et_stack_t = #now manacore.meta
# ============================================================
# sweetdream:equipment/armor/ebb_tide/wave_on —— 生物这一秒站在海浪上: +1 档
# ------------------------------------------------------------
# 【执行者】那只生物(@s)   【位置】at @s
# 【★ 打戳 + 加档必须在同一行流程里 ★】zx.et_on = #now 就是"这一秒在浪上"的凭据,
#   下面 ③ 的衰减只看它。用**计分项**而不是 tag(照共鸣 pass_set 的卡顿修复:
#   每刻给生物 add/remove tag 会让 chunk 每次都标脏)。
# ============================================================

scoreboard players operation @s zx.et_on = #now manacore.meta
scoreboard players add @s zx.et_e 1
execute if entity @e[tag=zx.et_set,distance=..2.5,limit=1] run scoreboard players add @s zx.et_e 1
execute if score @s zx.et_e matches 31.. run scoreboard players set @s zx.et_e 30
function sweetdream:equipment/armor/ebb_tide/speed_dn

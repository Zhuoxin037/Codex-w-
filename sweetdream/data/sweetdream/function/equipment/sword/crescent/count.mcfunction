# ============================================================
# sweetdream:equipment/sword/crescent/count —— 数"快捷栏里正在冷却的其它主动技能"
# ------------------------------------------------------------
# 【执行者】玩家   【出参】#cr_n zx.meta = 条数(0..9)
# 【怎么数】9 个快捷栏格逐个交给 slot(宏 {slot}); 它把"算不算"写在 #cr_hit 上。
#   ★ #cr_hit / #cr_n 都是**假玩家**(全局), 但整条链只在"一次平A"里跑完,
#     中间不跨刻, 所以不会互相串(同款: lib/atk_charge 的注释解释了为什么不能跨入口复用)。
# ============================================================

scoreboard players set #cr_n zx.meta 0

function sweetdream:equipment/sword/crescent/slot {slot:0}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:1}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:2}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:3}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:4}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:5}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:6}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:7}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1
function sweetdream:equipment/sword/crescent/slot {slot:8}
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_n zx.meta 1

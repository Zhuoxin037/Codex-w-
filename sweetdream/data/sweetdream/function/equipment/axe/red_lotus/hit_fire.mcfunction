# ============================================================
# sweetdream:equipment/axe/red_lotus/hit_fire —— 一层「流火」的一次打击
# ------------------------------------------------------------
# 【谁调用它】red_lotus/step_fire(已先调 recalc 把伤害写进 zx:work rl.dmg1)
# 【执行者】施法者本人(玩家)   【位置】施法者所在处
# 【打谁】施法者 5 格内的全部生物, 伤害 = 施法者基础攻击力 ×1(本段刚算好)
# 【归属】用 zx:work rl.u0..u3 走 with_from —— 不依赖施法者实体在不在场。
# 【★ 2026-10-07 改 ★】以前这里的执行者是"带流火的那只生物"(只当次数锚点);
#   现在由 step_fire 先摘名单再调它, 执行者就是施法者本人, 位置也是他本人。
# 【★ 2026-10-09 超限 ★】半径 5 -> 6 格; 并补"使其燃烧 2 秒"(基础版没有燃烧)。
# ============================================================

data modify storage zx:work a.num set from storage zx:work rl.dmg1
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..5]"
# 超限: 范围 5 格 -> 6 格
execute if score @s zx.rl_ol matches 1 run data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..6]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work rl.u0
data modify storage zx:work a.u1 set from storage zx:work rl.u1
data modify storage zx:work a.u2 set from storage zx:work rl.u2
data modify storage zx:work a.u3 set from storage zx:work rl.u3
function sweetdream:internal/damage/with_from with storage zx:work a

# 超限: 并使其燃烧 2 秒(40 tick, 只延长不缩短)
execute if score @s zx.rl_ol matches 1 run data modify storage zx:work rl.n set value 40
execute if score @s zx.rl_ol matches 1 as @e[type=!#sweetdream:no_damage,distance=..6] run function sweetdream:equipment/axe/red_lotus/ignite with storage zx:work rl

particle minecraft:flame ~ ~0.5 ~ 1.0 0.3 1.0 0.03 12 normal

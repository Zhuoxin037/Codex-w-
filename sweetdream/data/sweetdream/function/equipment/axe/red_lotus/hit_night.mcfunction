# ============================================================
# sweetdream:equipment/axe/red_lotus/hit_night —— 一层「夜火」的一次打击
# ------------------------------------------------------------
# 【谁调用它】red_lotus/step_night(已先调 recalc 把伤害写进 zx:work rl.dmg3)
# 【执行者】施法者本人(玩家)   【位置】施法者所在处
# 【打谁】施法者 6 格内的全部生物, 伤害 = 施法者基础攻击力 ×3(本段刚算好)
# 【★ 2026-10-07 改 ★】同 hit_fire: 执行者不再是"带夜火的那只生物", 而是施法者本人。
# 【★ 2026-10-09 超限 ★】"一次" -> "两次"(同一 tick 两下); 半径仍是 6 格;
#   并补"使其燃烧 5 秒"。
# ============================================================

data modify storage zx:work a.num set from storage zx:work rl.dmg3
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..6]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work rl.u0
data modify storage zx:work a.u1 set from storage zx:work rl.u1
data modify storage zx:work a.u2 set from storage zx:work rl.u2
data modify storage zx:work a.u3 set from storage zx:work rl.u3
function sweetdream:internal/damage/with_from with storage zx:work a

# 超限: 再打一次(同一个数值, rl.dmg3 没被动过)
#   "两次"是同一 tick 连着两下 —— 伤害类型走 bypasses_cooldown(见 api/damage 的注释),
#   不会被无敌帧吃掉第二下(和横刀超限"打两次"同一个道理)。
execute if score @s zx.rl_ol matches 1 run function sweetdream:internal/damage/with_from with storage zx:work a

# 超限: 并使其燃烧 5 秒(100 tick, 只延长不缩短)
execute if score @s zx.rl_ol matches 1 run data modify storage zx:work rl.n set value 100
execute if score @s zx.rl_ol matches 1 as @e[type=!#sweetdream:no_damage,distance=..6] run function sweetdream:equipment/axe/red_lotus/ignite with storage zx:work rl

particle minecraft:soul_fire_flame ~ ~0.5 ~ 1.2 0.3 1.2 0.03 14 normal

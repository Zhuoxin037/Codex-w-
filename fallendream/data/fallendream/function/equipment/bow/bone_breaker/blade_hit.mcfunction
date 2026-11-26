# ============================================================
# fallendream:equipment/bow/bone_breaker/blade_hit —— 一把刀这一刻撞到目标的伤害
# ------------------------------------------------------------
# 【执行者】刀刃   【前置】zx.bb_hit 已打在唯一目标上; zx.bb_dmg = 伤害 ×1000
# 【伤害】自身基础攻击力 ×0.3(在 recalc 里算好, 每 20 刻刷新)
# 【投递口径】照抄 dragon_tongue/rain_deal ⑦:
#   `a` 整个重设(不留上一次的 fixed/src 残留) → 类型可被 zx:config 覆盖 →
#   num → lib/num/plain → internal/damage/with_from(带主人归属)。
# ============================================================

data modify storage zx:work a set value {target:"@e[tag=zx.bb_hit,limit=1]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
execute store result storage zx:work a.damage double 0.001 run scoreboard players get @s zx.bb_dmg
data modify storage zx:work a.num set from storage zx:work a.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work a.s2_b_damage
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra

# ⑥ 超限：同一生物每累计 6 次碎刀伤害 -> 额外 基础攻击力 ×3 真实伤害 + 2 秒缓慢Ⅲ + 噬心
#   ★ 计数记在**目标**身上(文案"同一生物"), 不记在刀刃上 —— 否则同组 5 把刀各记各的,
#     "累计"就变成"每把各攒 6 次"。
#   ★ 必须排在普通伤害**之后**: 到第 6 次这一击, 先吃这一刀本身的 ×0.5, 再吃回响。
execute if score @s zx.bb_ol matches 1 as @e[tag=zx.bb_hit,distance=0..,limit=1] run scoreboard players add @s zx.bb_cnt 1
execute if score @s zx.bb_ol matches 1 store result storage zx:work bbb.base1000 int 1 run scoreboard players get @s zx.bb_base
execute if score @s zx.bb_ol matches 1 run data modify storage zx:work bbb.u0 set from entity @s data.zx.u[0]
execute if score @s zx.bb_ol matches 1 run data modify storage zx:work bbb.u1 set from entity @s data.zx.u[1]
execute if score @s zx.bb_ol matches 1 run data modify storage zx:work bbb.u2 set from entity @s data.zx.u[2]
execute if score @s zx.bb_ol matches 1 run data modify storage zx:work bbb.u3 set from entity @s data.zx.u[3]
execute if score @s zx.bb_ol matches 1 as @e[tag=zx.bb_hit,distance=0..,limit=1,scores={zx.bb_cnt=6..}] at @s run function fallendream:equipment/bow/bone_breaker/burst

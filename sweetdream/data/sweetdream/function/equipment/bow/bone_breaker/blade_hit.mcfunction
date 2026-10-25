# ============================================================
# sweetdream:equipment/bow/bone_breaker/blade_hit —— 一把刀这一刻撞到目标的伤害
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
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

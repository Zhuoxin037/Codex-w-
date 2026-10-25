# ============================================================
# sweetdream:equipment/sword/thunder_wedge/ol_dot_one —— 超限·雷楔 DoT 的单只结算
# ------------------------------------------------------------
# 【执行者】带 DoT 的那只生物   【位置】它脚下   【调用方】ol_tick ⑦
# 【入参】zx:work twgdot {c,x,u0..u3}  —— 当前魔力×0.07 / 最大魔力×0.08 / 施法者 UUID
# 【档位】zx.twg_dotk: 1 = 普通(3 秒, 当前魔力口径) / 2 = 强化(5 秒, 最大魔力口径)
# 【★ 为什么要带 u0..u3 而不是走 lib/uuid ★】本文件 @s 是**怪物**,
#   lib/uuid 记的是它自己的 uuid; 归属必须来自 marker 上那次快照。
# ============================================================

scoreboard players set #twg_dk zx.meta 0
execute store result score #twg_dk zx.meta run scoreboard players get @s zx.twg_dotk

data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack",num:0.0}
execute if score #twg_dk zx.meta matches 1 run data modify storage zx:work a.num set from storage zx:work twgdot.c
execute if score #twg_dk zx.meta matches 2 run data modify storage zx:work a.num set from storage zx:work twgdot.x
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work twgdot.u0
data modify storage zx:work a.u1 set from storage zx:work twgdot.u1
data modify storage zx:work a.u2 set from storage zx:work twgdot.u2
data modify storage zx:work a.u3 set from storage zx:work twgdot.u3
function sweetdream:internal/damage/with_from with storage zx:work a

# 表现: 身上还在跳电
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 0.3 0.6 0.3 0.08 6 normal

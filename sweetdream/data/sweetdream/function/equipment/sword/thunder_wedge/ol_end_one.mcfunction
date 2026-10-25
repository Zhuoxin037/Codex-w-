# ============================================================
# sweetdream:equipment/sword/thunder_wedge/ol_end_one —— 超限·雷楔 收尾: 给一只生物落一道雷
# ------------------------------------------------------------
# 【执行者】范围内的一只生物   【位置】它脚下   【调用方】ol_end ③
# 【入参】zx:work twgdot {dmg,u0..u3} —— 施放那一刻算好的 基础攻击力×2 与施法者 UUID
# 【做什么】① 真闪电落在它脚下 ② 对它 1 格内打一次 ×2 ③ 挂 DoT ④ 跑公共闪电钩子
# 【★ 与 strike 的三点不同 ★】
#   · 没有每秒一次的节流(zx.twg_gate): 收尾雷是一次性的, 不需要闸;
#   · 伤害值不读 marker 的 NBT —— @s 已经不是 marker 了, 从 twgdot 里取;
#   · 挂 DoT 用的是同一个 ol_dot_apply(收尾雷同样是"被闪电命中")。
# 【★ on_lightning 那行不能写 `at @s` ★】位置必须停在落点(生物脚下)而不是施法者脚下,
#   否则"负离子 / 超•负•荷"这类跨武器钩子会拿错落点(RULES 坑 154 ②)。
# ============================================================

# ① 真闪电(带 zx.th_own = 玩家用武器劈出来的雷, 见 strike 文件头的说明)
summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_own"]}

# ② 1 格内的生物吃一次 基础攻击力 ×2
data modify storage zx:work a set value {target:"@e[type=!#sweetdream:no_damage,distance=..1]",type:"minecraft:player_attack",num:0.0}
data modify storage zx:work a.num set from storage zx:work twgdot.dmg
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work twgdot.u0
data modify storage zx:work a.u1 set from storage zx:work twgdot.u1
data modify storage zx:work a.u2 set from storage zx:work twgdot.u2
data modify storage zx:work a.u3 set from storage zx:work twgdot.u3
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 被这一道雷命中的那批挂 DoT(与 strike ④.5 同一个入口)
execute as @e[type=!#sweetdream:no_damage,distance=..1] at @s run function sweetdream:equipment/sword/thunder_wedge/ol_dot_apply

# ④ "自身召唤闪电"的公共收尾钩子: @s 换成施法者, 位置仍是落点
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:lib/on_lightning

# ⑤ 表现
particle minecraft:electric_spark ~ ~0.6 ~ 0.7 0.9 0.7 0.2 24 normal

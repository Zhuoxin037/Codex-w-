# ============================================================
# sweetdream:equipment/bow/bone_breaker/blade_tick —— 「碎刀」一把刀的每一刻
# ------------------------------------------------------------
# 【谁调用它】core/tick: 三维度各一行 `in <dim> as @e[tag=zx.bb_blade,distance=0..] at @s`
# 【执行者】刀刃(item_display)   【位置】刀刃自己
# 【每一刻干什么】① 寿命 -1(归零即销毁)  ② 反查主人  ③ 角度 +1
#                ④ 摆到准星前(blade_place)  ⑤ 每 20 刻重算伤害  ⑥ 碰到谁就打谁
# 【★ 为什么"每刻碰到就打"不用自己节流 ★】2026-10-25 起本包伤害**吃原版受伤
#   无敌帧**(0.5 秒) ⇒ 同一目标每 0.5 秒只会真正吃到一次，其余命中被引擎吞掉。
#   这正是文案"碰到就造成伤害"应有的手感(不是 20 次/秒的绞肉机)。
#   别在这里加"每 10 刻才判一次"之类的自造节流 —— 那会让刀刃穿过目标时反而打不到。
# ============================================================

# ① 寿命 8 秒 = 160 刻
scoreboard players remove @s zx.bb_life 1
execute if score @s zx.bb_life matches ..0 run return run kill @s

# ② 反查主人(零 NBT: 4 个整数比较)
#   ★ 必须逐字段灌: ub 要的是 {u0,u1,u2,u3} 四个键, 而 NBT 里存的是 [I;...] 数组。
data modify storage zx:work ub set value {}
data modify storage zx:work ub.u0 set from entity @s data.zx.u[0]
data modify storage zx:work ub.u1 set from entity @s data.zx.u[1]
data modify storage zx:work ub.u2 set from entity @s data.zx.u[2]
data modify storage zx:work ub.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/u_by
#   主人不在(下线 / 换维度) ⇒ 这把刀没有存在的意义, 直接收掉
execute unless entity @a[tag=zx.ub,limit=1] run kill @s
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ③ 角度 +1(24 档循环)
scoreboard players add @s zx.bb_a 1
execute if score @s zx.bb_a matches 24.. run scoreboard players operation @s zx.bb_a -= #24 zx.meta

# ④ 摆到"准星前绕圈"的那一档
function sweetdream:equipment/bow/bone_breaker/blade_place

# ⑤ 每 20 刻跟着面板重算一次伤害(基础攻击力会随 buff / 换装备变)
scoreboard players operation #bb_ph zx.meta = #now manacore.meta
scoreboard players operation #bb_ph zx.meta %= #20 zx.meta
execute if score #bb_ph zx.meta matches 0 run data modify storage zx:work bbk.uid set from entity @s data.zx.uid
execute if score #bb_ph zx.meta matches 0 run function sweetdream:equipment/bow/bone_breaker/recalc
execute if score #bb_ph zx.meta matches 0 store result score @s zx.bb_dmg run data get storage zx:work bbk.dmg1000

# ⑥ 碰到谁了? —— 一支刀刃那么大的判定箱(1.2 宽 × 2.0 高), 取最近的一只
tag @e[tag=zx.bb_hit,distance=0..] remove zx.bb_hit
execute at @s positioned ~-0.6 ~-1.0 ~-0.6 as @e[type=!#sweetdream:no_damage,dx=1.2,dy=2.0,dz=1.2,limit=1,sort=nearest] run tag @s add zx.bb_hit
execute unless entity @e[tag=zx.bb_hit,distance=0..,limit=1] run return 0
function sweetdream:equipment/bow/bone_breaker/blade_hit
tag @e[tag=zx.bb_hit,distance=0..] remove zx.bb_hit

# ⑦ 表现: 刀刃自己带一层划痕, 让"它在转"看得出来
particle minecraft:crit ~ ~0.4 ~ 0.12 0.25 0.12 0.0 2 normal

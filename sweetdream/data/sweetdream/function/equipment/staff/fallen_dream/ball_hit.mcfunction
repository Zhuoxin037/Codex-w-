# ============================================================
# sweetdream:equipment/staff/fallen_dream/ball_hit —— 堕梦普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步: `function $(hit) with entity @s data`
#   (@s = 法球本体, 位置 = 命中点; 宏参数 = 球的全部 data)
#   ⚠️ 此刻 zx.ball_hit 标签还没摘(ball/hit 第 ⑦ 步才清) —— 命中的生物
#   就用 @e[tag=zx.ball_hit] 圈出来。
# 【文案】若命中的生物处于「白昼梦」效果, 本次伤害变为真实伤害。
# 【为什么按 dream 分两批打】带梦的走 sweetdream:true_damage, 不带梦的走
#   默认类型(zx:config damage_type = skill) —— 一次回调两段, 各打各的。
#   ⚠️ 不摘「白昼梦」! 描述只说"变为真实伤害", 消耗梦是清醒梦的机制。
# 【dmg = 0 的那一下】ball/hit 第 ④ 步已经打过 0 点伤害(原版对 0 伤害
#   不生效, 无副作用), 真正的伤害全部在这里结算。
# ============================================================

# ⓪ 球上没带伤害(fdmg 缺失) → 直接收工(缺字段会让宏调用静默失败, 先拦)
execute unless data entity @s data.fdmg run return 0

# ① 带梦目标 → 真实伤害(sweetdream:true_damage, 穿甲口径见 damage_type 定义)
data modify storage zx:work a set value {target:"@e[tag=zx.ball_hit,tag=zx.status.dream]",damage:0.0,type:"sweetdream:true_damage",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work a.num set from entity @s data.fdmg
function sweetdream:lib/num/plain
data modify storage zx:work a.u0 set from entity @s data.u0
data modify storage zx:work a.u1 set from entity @s data.u1
data modify storage zx:work a.u2 set from entity @s data.u2
data modify storage zx:work a.u3 set from entity @s data.u3
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a

# ② 不带梦目标 → 普通技能伤害
data modify storage zx:work a set value {target:"@e[tag=zx.ball_hit,tag=!zx.status.dream]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.num set from entity @s data.fdmg
function sweetdream:lib/num/plain
data modify storage zx:work a.u0 set from entity @s data.u0
data modify storage zx:work a.u1 set from entity @s data.u1
data modify storage zx:work a.u2 set from entity @s data.u2
data modify storage zx:work a.u3 set from entity @s data.u3
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 带梦命中的小表现(让"打真伤"看得见)
execute as @e[tag=zx.ball_hit,tag=zx.status.dream] at @s run particle minecraft:witch ~ ~1 ~ 0.4 0.6 0.4 0.02 12 normal

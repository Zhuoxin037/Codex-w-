# ============================================================
# sweetdream:equipment/staff/fallen_dream/one —— 堕梦: 对一只时停生物结算一秒
# ------------------------------------------------------------
# 【谁调用它】second 里 `execute as @e[tag=zx.fd_t] at @s`(执行者 = 目标)
# 【文案】在时停期间每秒受到一次相当于使用者(释放者)当前魔力值 ×0.04 的伤害。
# 【脱离时停就停】"时停期间"的限定: 目标不带 zx.stop(自然到期被解冻 sweep
#   摘了 / 被别的解冻手段摘了) → 摘 DoT 标记收工, 不再另设计时器。
# 【伤害基数实时算】每秒用 data.zx.fd.uuid 查释放者的当前魔力 —— 释放者
#   掉蓝/回蓝下一秒就反映到 DoT 上(口径是"使用者当前魔力值")。
#   释放者离线时查不到 → 伤害为 0(优雅降级)。
# 【归属】u0..u3 预置进 zx:in arg(api/damage 在生物上下文里不会覆盖),
#   击杀记在释放者头上。
# ============================================================

# ① 已经不在时停里 → 摘标记收工
execute unless entity @s[tag=zx.stop] run tag @s remove zx.fd_t
execute unless entity @s[tag=zx.fd_t] run return 0

# ② 算伤害 = 释放者当前魔力 ×0.04
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from entity @s data.zx.fd.uuid
function manacore:api/mana/get
scoreboard players set #dmg zx.meta 0
execute store result score #dmg zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #dmg zx.meta *= #4 zx.meta

# ③ 打出去(带释放者归属)
data modify storage zx:in arg set value {target:"@s",damage:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:in arg.damage double 0.0001 run scoreboard players get #dmg zx.meta
data modify storage zx:in arg.u0 set from entity @s data.zx.fd.u0
data modify storage zx:in arg.u1 set from entity @s data.zx.fd.u1
data modify storage zx:in arg.u2 set from entity @s data.zx.fd.u2
data modify storage zx:in arg.u3 set from entity @s data.zx.fd.u3
function sweetdream:api/damage

# ④ 表现
execute at @s run particle minecraft:witch ~ ~1 ~ 0.4 0.6 0.4 0.02 10 normal

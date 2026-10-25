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
# 【超限·堕梦(2026-10-23 批 K9)】系数 ×0.04 → **×0.05**; 且"受到超过 6 次本次伤害后"
#   后续提升为 **×0.08** ⇒ 这里要数次数(zx.fd_n)并按档取系数。
#   ★ 系数/次数只能记在**目标身上**: 本函数是"每只被时停的生物"各自在跑(second 驱动),
#     拿不到释放者, 更读不到他手上的杖 ⇒ 由 skill ⑨.5 在挂 DoT 时拍进来。
# ============================================================

# ① 已经不在时停里 → 摘标记收工(顺手把两个临时量清掉, 别留在生物身上)
execute unless entity @s[tag=zx.stop] run tag @s remove zx.fd_t
execute unless entity @s[tag=zx.fd_t] run scoreboard players set @s zx.fd_n 0
execute unless entity @s[tag=zx.fd_t] run scoreboard players set @s zx.fd_ol 0
execute unless entity @s[tag=zx.fd_t] run return 0

# ② 算伤害 = 释放者当前魔力 ×0.04(超限 ×0.05; 超过 6 次之后 ×0.08)
#   ★ #dmg 的单位是"魔力 ×100"(上一句 data get 100), 所以系数写 4 / 5 / 8
#     分别对应 ×0.04 / ×0.05 / ×0.08(最后 ×0.0001 还原)。
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from entity @s data.zx.fd.uuid
function manacore:api/mana/get
scoreboard players set #dmg zx.meta 0
execute store result score #dmg zx.meta run data get storage manacore:out r.value 100

# ②.5 ★ 先数次数、再选系数 ★ —— 顺序不能反:
#   "受到**超过 6 次**本次伤害后" ⇒ 第 7 次起才走 ×0.08, 前 6 次仍按 ×0.05。
#   所以必须**先**按当前次数(还没加这一下)判档, 判完再 +1。
scoreboard players add @s zx.fd_n 0
scoreboard players set #fd_k zx.meta 4
execute if score @s zx.fd_ol matches 1 run scoreboard players set #fd_k zx.meta 5
execute if score @s zx.fd_ol matches 1 if score @s zx.fd_n matches 7.. run scoreboard players set #fd_k zx.meta 8
scoreboard players operation #dmg zx.meta *= #fd_k zx.meta
scoreboard players add @s zx.fd_n 1

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

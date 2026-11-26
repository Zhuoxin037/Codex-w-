# ============================================================
# fallendream:equipment/armor/purge_fire/stack_hit —— 涤火(超限)：对自己标记过的生物造成伤害
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}（施法者 / 动手那个人的 UUID 四段）
# 【执行者】被打的那一只（@s = 目标）
# 【调用点】internal/damage/one —— 排在 deal **之后**；调用处已本地判过 `@s[tag=zx.pf_tgt]`
# 【文案(逐字)】"…且自身每对其造成一次伤害则自身基础攻击力 +1，每次单独持续 12 秒。"
# 【★ 认人 ★】"自身"= 穿超限涤火的那个人 —— ob 里只有 UUID, 只能用 lib/u_by 反查
#   （与候潮/沸痕同一套做法; 调用处先用目标身上的 zx.pf_tgt 挡掉绝大多数情况）。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

scoreboard players set #pfs_on zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["purge_fire"],ol:"purge_fire"}] run scoreboard players set #pfs_on zx.meta 1
execute unless score #pfs_on zx.meta matches 1 run return 0

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function fallendream:equipment/armor/purge_fire/stack_gain

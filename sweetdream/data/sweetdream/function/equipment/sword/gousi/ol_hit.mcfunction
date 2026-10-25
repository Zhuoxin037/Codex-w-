# ============================================================
# sweetdream:equipment/sword/gousi/ol_hit —— 超限·钩丝 那一下伤害(执行者 = 被拉的生物)
# ------------------------------------------------------------
# 【入参】#gs_k zx.meta = 千分比系数(12 = ×0.12, 8 = ×0.08)
# 【执行者】被拉的生物(不是玩家) —— 所以一切都得从 zx:work gs3 里取:
#   · 魔力基数要用施法者的 max_mana => 用 gs3.uu 去 manacore 读
#     (不能走 lib/uuid, 那读的是 @s 自己 = 怪物)
#   · 伤害归属要给施法者 => 用 gs3.u0..u3 显式带上(不能用 lib/find_by:
#     手上只有 UUID[0] 一个整数, 拼不出 nbt={UUID:[I;...]} 的完整选择器)
# 【★ 定点算法照抄原版 land_hit ★】r.max 是 double, 先 ×10 取成"十分位整数",
#   再 ×k ÷1000 —— 直接 ÷100 会把 48 变成 4, 精度全丢。
# ============================================================

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work gs3.uu
function manacore:api/mana/get

scoreboard players set #gs_mm zx.meta 0
execute store result score #gs_mm zx.meta run data get storage manacore:out r.max 10
scoreboard players operation #gs_d zx.meta = #gs_mm zx.meta
scoreboard players operation #gs_d zx.meta *= #gs_k zx.meta
scoreboard players operation #gs_d zx.meta /= #1000 zx.meta
execute if score #gs_d zx.meta matches ..0 run scoreboard players set #gs_d zx.meta 1

data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack"}
execute store result storage zx:work a.num double 1 run scoreboard players get #gs_d zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work gs3.u0
data modify storage zx:work a.u1 set from storage zx:work gs3.u1
data modify storage zx:work a.u2 set from storage zx:work gs3.u2
data modify storage zx:work a.u3 set from storage zx:work gs3.u3
function sweetdream:internal/damage/with_from with storage zx:work a

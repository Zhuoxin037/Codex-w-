# ============================================================
# fallendream:equipment/armor/purge_fire/stack_sync —— 涤火(超限)：按活着的槽数校准基础攻击力
# ------------------------------------------------------------
# 【执行者】玩家   【谁调它】stack_gain（拿到新层当刻）/ lib/second 的每秒玩家扫描
# 【干什么】8 个槽里过期的清零、还活着的计数 = #pfs_w; 与账本 zx.pf_kv 比差值,
#   差值直接加到面板 base_attack(每层 +1)。差值制 ⇒ 换装 / 掉线 / 死亡重置都不会漂。
# 【★ 计分项"没分数"不是 0 ★】先用 `add 0` 建出来, 否则 `if score … matches 1..` 不成立,
#   过期槽永远清不掉(会伪造成"永远活着")。
# 【★ 差值只写 base_attack 面板 ★】panel 的 base_attack 就是"基础攻击力"的公开口径
#   (见 api/stats/get); 与涤火 +30% 那条(自己的账本 zx.pf_atk)各算各的差值, 互不覆盖。
# ============================================================

scoreboard players add @s zx.pf_kv 0
scoreboard players set #pfs_w zx.meta 0
scoreboard players add @s zx.pf_k1 0
scoreboard players add @s zx.pf_k2 0
scoreboard players add @s zx.pf_k3 0
scoreboard players add @s zx.pf_k4 0
scoreboard players add @s zx.pf_k5 0
scoreboard players add @s zx.pf_k6 0
scoreboard players add @s zx.pf_k7 0
scoreboard players add @s zx.pf_k8 0

execute if score @s zx.pf_k1 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1
execute if score @s zx.pf_k2 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1
execute if score @s zx.pf_k3 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1
execute if score @s zx.pf_k4 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1
execute if score @s zx.pf_k5 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1
execute if score @s zx.pf_k6 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1
execute if score @s zx.pf_k7 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1
execute if score @s zx.pf_k8 > #now manacore.meta run scoreboard players add #pfs_w zx.meta 1

execute if score @s zx.pf_k1 matches 1.. unless score @s zx.pf_k1 > #now manacore.meta run scoreboard players set @s zx.pf_k1 0
execute if score @s zx.pf_k2 matches 1.. unless score @s zx.pf_k2 > #now manacore.meta run scoreboard players set @s zx.pf_k2 0
execute if score @s zx.pf_k3 matches 1.. unless score @s zx.pf_k3 > #now manacore.meta run scoreboard players set @s zx.pf_k3 0
execute if score @s zx.pf_k4 matches 1.. unless score @s zx.pf_k4 > #now manacore.meta run scoreboard players set @s zx.pf_k4 0
execute if score @s zx.pf_k5 matches 1.. unless score @s zx.pf_k5 > #now manacore.meta run scoreboard players set @s zx.pf_k5 0
execute if score @s zx.pf_k6 matches 1.. unless score @s zx.pf_k6 > #now manacore.meta run scoreboard players set @s zx.pf_k6 0
execute if score @s zx.pf_k7 matches 1.. unless score @s zx.pf_k7 > #now manacore.meta run scoreboard players set @s zx.pf_k7 0
execute if score @s zx.pf_k8 matches 1.. unless score @s zx.pf_k8 > #now manacore.meta run scoreboard players set @s zx.pf_k8 0

scoreboard players operation #pfs_d zx.meta = #pfs_w zx.meta
scoreboard players operation #pfs_d zx.meta -= @s zx.pf_kv
execute if score #pfs_d zx.meta matches 0 run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #pfs_d zx.meta
function manacore:api/stats/add
scoreboard players operation @s zx.pf_kv = #pfs_w zx.meta

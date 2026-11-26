# ============================================================
# fallendream:equipment/armor/empty_camp/ol_melee —— 超限·空营：满层平A 给自己 +3% 基础攻击力
# ------------------------------------------------------------
# 【谁调它】进度 fallendream:equipment/armor/empty_camp_ol_hit（player_hurt_entity，只认平A）
# 【执行者】动手的那个玩家
# 【文案】"满层时自身额外获得抗性提升二效果，且自身每次普通近战时自身基础攻击力都会
#   +3%，每 5 秒最多触发一次。"
# 【★ 永久叠加、不计时 ★】文案没给加成时长 ⇒ 每 5 秒一次、每次 +3% 基础攻击力，
#   一直留着（摘甲也不退；没有"失去满层就退"的原文）。
# 【★ 基准固定 ★】每层都按"**基础**攻击力的 3%"，要先用「当前面板 − 已加总额」还原
#   原始基准，否则 1.03^n 复利，叠 10 次就变成 +34% 而不是 +30%。
# 【★ 差值制 ★】zx.ec_badd = 已加到面板上的总量(×1000)，每次只补增量；
#   R05：×3 前先夹到 INT32_MAX ÷ 3。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/empty_camp_ol_hit

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"],ol:"empty_camp"}] run return 0
execute unless score @s zx.ec_a matches 6 run return 0
function fallendream:lib/hp_pct
execute if score #hp_p100 zx.meta matches ..9999 run return 0
scoreboard players add @s zx.ec_cd 0
execute if score @s zx.ec_cd > #now manacore.meta run return 0

# ① 当前面板基础攻击力(×1000) - 已加总额 = 原始基准
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #ec_cur zx.meta 0
execute store result score #ec_cur zx.meta run data get storage manacore:out r.value 1000
scoreboard players add @s zx.ec_badd 0
scoreboard players operation #ec_base zx.meta = #ec_cur zx.meta
scoreboard players operation #ec_base zx.meta -= @s zx.ec_badd

# ② 基准 ×3 ÷100 = 这一层的 3%（×1000 定点，R05 夹上界）
scoreboard players set #ec_cap zx.meta 2147483647
scoreboard players set #ec_3 zx.meta 3
scoreboard players operation #ec_cap zx.meta /= #ec_3 zx.meta
execute if score #ec_base zx.meta > #ec_cap zx.meta run scoreboard players operation #ec_base zx.meta = #ec_cap zx.meta
scoreboard players operation #ec_add zx.meta = #ec_base zx.meta
scoreboard players operation #ec_add zx.meta *= #ec_3 zx.meta
scoreboard players set #ec_100 zx.meta 100
scoreboard players operation #ec_add zx.meta /= #ec_100 zx.meta
execute if score #ec_add zx.meta matches ..0 run return 0

# ③ 补差写面板 + 累加账本
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #ec_add zx.meta
function manacore:api/stats/add
scoreboard players operation @s zx.ec_badd += #ec_add zx.meta

# ④ 5 秒闸（100 刻）+ 表现
scoreboard players operation @s zx.ec_cd = #now manacore.meta
scoreboard players add @s zx.ec_cd 100
execute at @s run particle minecraft:crit ~ ~1 ~ 0.3 0.4 0.3 0.05 8 normal

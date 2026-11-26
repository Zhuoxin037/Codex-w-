# ============================================================
# fallendream:lib/fm/read —— 每秒把"术阵位占用 / 上限"读进玩家计分项
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a run ...
# 【执行者】玩家(@s)
# 【出参】@s zx.fm_u = 已占用术阵位数
#         @s zx.fm_c = 当前术阵位上限（= stats.formation_limit，默认 3）
# 【为什么每秒一次】枢/承/屏息/独行 的判据全是"占用几个 / 满没满"，而术阵的增删
#   本来就只有技能施放那几个瞬间 ⇒ 秒级完全够；每刻去问前置包等于每刻读一遍
#   玩家记录（卡顿坑 1）。
# 【★ 术阵是纯占位 ★】本读数只反映"玩家名下登记了几个术阵"，与它有没有实体无关
#   （见 _tags_data.py 口径 5）。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 没分数 = 0 个（store 读不到时不会执行 ⇒ 先归零）
scoreboard players set @s zx.fm_u 0
scoreboard players set @s zx.fm_c 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count

execute store result score @s zx.fm_u run data get storage manacore:out r.count
execute store result score @s zx.fm_c run data get storage manacore:out r.limit

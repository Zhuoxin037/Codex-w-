# ============================================================
# sweetdream:status/decay_stg —— 「升痕」每 15 秒 −1 层
# ------------------------------------------------------------
# 【执行者】带升痕的那只生物(decay 已 `as+at @s` 送进来; 层数 1..3)
# 【计时】zx.stg_t(秒)。施加时 skyvault/mark 设 15; 这里每秒 −1, 到 ≤0 掉 1 层。
# 【掉完一层怎么办】计时重置为 15 —— 即"每层各自数 15 秒, 但共用一根计时"。
# 【① 是兜底】同 decay_shenghen: 老存档里带升痕却没计时分数的补满 15。
# ============================================================

# ① 兜底: 没有计时分数 -> 补满 15
execute unless score @s zx.stg_t matches -2147483648.. run scoreboard players set @s zx.stg_t 15

# ② 每秒 −1
scoreboard players remove @s zx.stg_t 1

# ③ 到点(计时 ≤0) -> 掉 1 层 + 计时重置为 15(为下一层重新计时)
execute if score @s zx.stg_t matches ..0 run scoreboard players remove @s zx.stg 1
execute if score @s zx.stg_t matches ..0 run scoreboard players set @s zx.stg_t 15

# ④ 层数已耗尽 -> 彻底清掉层数与计时(下一秒起脱离扫描)
execute unless score @s zx.stg matches 1.. run scoreboard players reset @s zx.stg
execute unless score @s zx.stg matches 1.. run scoreboard players reset @s zx.stg_t

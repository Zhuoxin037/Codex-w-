# ============================================================
# sweetdream:status/decay_shenghen —— 「圣痕」15 秒到点摘掉
# ------------------------------------------------------------
# 【执行者】带圣痕的那只生物(decay 已 `as+at @s` 送进来)
# 【计时】zx.sh_t(秒)。施加时 angel_core/mark 设 15; 这里每秒 −1, 到 ≤0 摘标签。
# 【① 是兜底】老存档里"已经带着圣痕、但没有计时分数"的只, 会在这补满 15 —
#   否则 `if score matches ..0` 对**不存在的分数**会直接失败, 它就永远摘不掉了。
# ============================================================

# ① 兜底: 没有计时分数 -> 补满 15
execute unless score @s zx.sh_t matches -2147483648.. run scoreboard players set @s zx.sh_t 15

# ② 每秒 −1
scoreboard players remove @s zx.sh_t 1

# ③ 到点 -> 摘标签 + 清计时(下一秒起脱离扫描)
execute if score @s zx.sh_t matches ..0 run tag @s remove zx.status.shenghen
execute if score @s zx.sh_t matches ..0 run scoreboard players reset @s zx.sh_t

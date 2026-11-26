# ============================================================
# fallendream:status/decay_shenghen —— 「圣痕」到点摘掉
# ------------------------------------------------------------
# 【执行者】带圣痕的那只生物(decay 已 `as+at @s` 送进来)
# 【计时】zx.sh_t(秒)。施加时 angel_core/mark 设满: 基础版 15 / 超限版 20
#   （2026-11-22 超限把圣痕时长从 15 抬到 20）；这里每秒 −1, 到 ≤0 摘掉。
# 【① 是兜底】老存档里"已经带着圣痕、但没有计时分数"的只, 会在这补满 15 —
#   否则 `if score matches ..0` 对**不存在的分数**会直接失败, 它就永远摘不掉了。
#   ★ 兜底一律补**基础值 15**：兜底时无从知道它是哪一档挂上去的，
#     少 5 秒只是略早消失，比"永远摘不掉"安全得多。
# 【③ 连带清 zx.sh_x】额外层没有自己的计时，圣痕一走它必须跟着走 ——
#   否则同一只重新被挂圣痕时会带着上一轮的"额外层"（mark 里虽然也会复位，
#   但那是新挂的时候；中途被 dmg2 清掉的情况没人复位）。
# ============================================================

# ① 兜底: 没有计时分数 -> 补满 15
execute unless score @s zx.sh_t matches -2147483648.. run scoreboard players set @s zx.sh_t 15

# ② 每秒 −1
scoreboard players remove @s zx.sh_t 1

# ③ 到点 -> 摘标签 + 清额外层 + 清计时(下一秒起脱离扫描)
#   ★ 顺序: 清 zx.sh_x 必须在 reset zx.sh_t **之前** ★
#     reset 之后 `if score @s zx.sh_t matches ..0` 就是"分数不存在"⇒ 恒假,
#     额外层会永远留在生物身上（新挂圣痕时只能靠 mark 复位，中途被 dmg2 清掉的没人复位）。
execute if score @s zx.sh_t matches ..0 run tag @s remove zx.status.shenghen
execute if score @s zx.sh_t matches ..0 run scoreboard players reset @s zx.sh_x
execute if score @s zx.sh_t matches ..0 run scoreboard players reset @s zx.sh_t

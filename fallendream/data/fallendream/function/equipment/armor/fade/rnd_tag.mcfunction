# ============================================================
# fallendream:equipment/armor/fade/rnd_tag —— 超限·息影: 给这一只目标附随机一大标签
# ------------------------------------------------------------
# 【执行者】@s = 被命中的生物（one 在 deal 之后逐个 as 进来）
# 【调用】one 里判 zx:work fd.tag=1b 时调；每个目标各掷一次
#   ("使受到伤害的生物额外附加五大标签的随机一种" —— 每个生物独立随机,
#    与 stellar_elegy/rnd_mark_one 同款)
# 【五标签词表】流火 / 夜火 / 噬心 / 渊海 / 白昼梦（lib/rnd %5 → 0..4）
# ============================================================

function fallendream:lib/rnd
scoreboard players operation #fd_r zx.meta = #rnd zx.meta
scoreboard players operation #fd_r zx.meta %= #5 zx.meta

execute if score #fd_r zx.meta matches 0 run function fallendream:tag/mark {target:"@s",mark:"liuhuo"}
execute if score #fd_r zx.meta matches 1 run function fallendream:tag/mark {target:"@s",mark:"yehuo"}
execute if score #fd_r zx.meta matches 2 run function fallendream:tag/mark {target:"@s",mark:"shixin"}
execute if score #fd_r zx.meta matches 3 run function fallendream:tag/mark {target:"@s",mark:"yuanhai"}
execute if score #fd_r zx.meta matches 4 run function fallendream:tag/mark {target:"@s",mark:"dream"}

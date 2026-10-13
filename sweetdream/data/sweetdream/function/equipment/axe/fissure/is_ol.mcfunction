# ============================================================
# sweetdream:equipment/axe/fissure/is_ol —— 「崩裂」手里这把是不是超限版
# ------------------------------------------------------------
# 【谁调用它】fissure/cast(施法那刻判一次)
# 【出参】#fi_ol zx.meta: 1 = 主手这把是「超限·崩裂」, 0 = 原版
# 【判据】主手物品的 custom_data 同时带 zx:["fissure"] 与 ol:"fissure"
# 【为什么 cast 里现判就够】崩裂的三处差异(前方格数 / 立即段倍率 / 裂缝时长)全在
#   本次施法内用完 —— 没有"跨刻之后手里换了武器"的场景, 所以不需要 zx.fi_ol 快照
#   (对比: 电弧的判定发生在箭命中那一刻, 才必须快照)。
# ============================================================

scoreboard players set #fi_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["fissure"],ol:"fissure"}] run scoreboard players set #fi_ol zx.meta 1

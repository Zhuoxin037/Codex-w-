# ============================================================
# fallendream:equipment/sword/mana_imbue/pay_calc —— 超限被动的扣费减免
# ------------------------------------------------------------
# 【入】#im_pay（已置 45）  【出】#im_pay = max(45 - 6 × 当前法球数, 15)
# 【法球数】取 tally 的 #jorbs = zx.j_orb + zx.j_prop（预言占用法球容量）
# 【为什么单独拆】imbue_hit 是热路径（每次命中都跑），原版分支一行都不用进这里。
# ============================================================

function fallendream:profession/mage/tally

scoreboard players set #im_red zx.meta 0
execute if score #jorbs zx.meta matches 1.. run scoreboard players operation #im_red zx.meta = #jorbs zx.meta
scoreboard players set #im_six zx.meta 6
scoreboard players operation #im_red zx.meta *= #im_six zx.meta
scoreboard players set #im_30 zx.meta 30
execute if score #im_red zx.meta > #im_30 zx.meta run scoreboard players set #im_red zx.meta 30
scoreboard players operation #im_pay zx.meta -= #im_red zx.meta

# 兜底：45 - 30 = 15，理论上到不了 0；真到了也不扣 0（0 费会让 lib/mana/pay 走免费分支）
execute if score #im_pay zx.meta matches 1.. run return 0
scoreboard players set #im_pay zx.meta 1

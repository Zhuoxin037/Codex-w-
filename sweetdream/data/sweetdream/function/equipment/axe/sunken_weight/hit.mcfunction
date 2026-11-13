# ============================================================
# sweetdream:equipment/axe/sunken_weight/hit —— 沉砣（铁斧 · 普攻）
# ------------------------------------------------------------
# 【技能原文】
#   "每次命中额外造成 4 点固定伤害（不参与任何加成），并获得 1 层「砣」，最多 5 层。
#    每层「砣」使该固定伤害 +2 点，并使自身移动速度降低 4%。
#    自身受到任何伤害时，「砣」立即清零。"
# 【★ 顺序：先按"当前层数"算伤害，再加层 ★】
#   设计写的顺序就是"造成 4 点 → 获得 1 层"，所以第 1 次命中是 4 点（不是 6 点），
#   到满层后稳定在 4 + 2×5 = 14 点。
# 【固定伤害】绕开 api/damage/calc：a.num 直接写这个整数。
# ============================================================
advancement revoke @s only sweetdream:equipment/axe/sunken_weight_hit

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sunken_weight"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sunken_weight"]}] run return 0

function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/axe/sunken_weight/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]

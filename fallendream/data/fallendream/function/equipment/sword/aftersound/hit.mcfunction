# ============================================================
# fallendream:equipment/sword/aftersound/hit —— 余响：平A命中入口（被动）
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/sword/aftersound_hit（player_hurt_entity）
# 【文案】每次普攻命中生物后，若自身当前术阵为空，则召唤一个持续 5 秒的术阵。
# ============================================================

advancement revoke @s only fallendream:equipment/sword/aftersound_hit
execute unless score @s zx.job matches 3 run return 0

function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

execute if items entity @s weapon.mainhand diamond_sword[custom_data~{zx:["aftersound"]}] run function fallendream:equipment/sword/aftersound/passive
execute if items entity @s weapon.offhand diamond_sword[custom_data~{zx:["aftersound"]}] run function fallendream:equipment/sword/aftersound/passive

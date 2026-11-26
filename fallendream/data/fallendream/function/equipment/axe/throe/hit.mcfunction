# ============================================================
# fallendream:equipment/axe/throe/hit —— 痛楚（斧·魔导士）：平A命中入口
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/throe_hit（player_hurt_entity，全包共用）
# 【文案】每次攻击命中生物后，若自身有法球，则消耗 1 个法球，使该生物额外受到
#   最大魔力值 ×0.03 的伤害，并使其在 2 秒内受到的伤害提升 10%。
#   之后若仍有法球，则额外消耗 1 个法球，对其 2 格内的全部生物造成一次
#   最大魔力值 ×0.03 的伤害，并将这些生物向其轻微吸引一次。
# ============================================================

advancement revoke @s only fallendream:equipment/axe/throe_hit
execute unless score @s zx.job matches 1 run return 0

function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["throe"]}] run return run function fallendream:equipment/axe/throe/hit_go
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["throe"]}] run function fallendream:equipment/axe/throe/hit_go

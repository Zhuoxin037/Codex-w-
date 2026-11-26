# ============================================================
# fallendream:equipment/armor/cross_dream/ol_thp —— 超限·渡梦: 20% 最大生命的临时生命
# ------------------------------------------------------------
# 【谁调用它】cross_dream/on_hurt ⑦（条件已判: 穿着超限渡梦）
# 【执行者】玩家（@s）
# 【文案(lore 逐字)】…之后自身获得相当于最大生命值20%的临时生命值，持续15秒。
# 【口径】20% 读**原版属性 max_health**（与 lib/heal / lib/max_health_score 同源），
#   向下取整；到期刻由调用方写进 zx.thp_end（300 刻 = 15 秒）。
# ============================================================

execute store result score #cd_hp zx.meta run attribute @s minecraft:max_health get
scoreboard players set #cd_20 zx.meta 20
scoreboard players operation #cd_hp zx.meta *= #cd_20 zx.meta
scoreboard players operation #cd_hp zx.meta /= #100 zx.meta
execute if score #cd_hp zx.meta matches ..0 run return 0

scoreboard players operation #thp_v zx.meta = #cd_hp zx.meta
function fallendream:lib/thp/add

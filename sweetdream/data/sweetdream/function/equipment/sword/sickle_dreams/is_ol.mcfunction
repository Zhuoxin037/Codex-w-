# ============================================================
# sweetdream:equipment/sword/sickle_dreams/is_ol —— 手里这把是不是**超限版**引梦镰
# ------------------------------------------------------------
# 【出参】#sd_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 主手 + 副手都判 ★】这把镰刀本来就支持"副手也能放"(见 cast ⑥.5),
#   所以两只手都得看。
# 【判据】custom_data 里 zx 含本装备 id **且** ol 等于本装备 id(见 overlimit/api/fit)。
# ============================================================

scoreboard players set #sd_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["sickle_dreams"],ol:"sickle_dreams"}] run scoreboard players set #sd_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["sickle_dreams"],ol:"sickle_dreams"}] run scoreboard players set #sd_ol zx.meta 1

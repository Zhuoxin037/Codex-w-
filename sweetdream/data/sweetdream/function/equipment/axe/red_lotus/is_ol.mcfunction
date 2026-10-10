# ============================================================
# sweetdream:equipment/axe/red_lotus/is_ol —— 手里这把是不是**超限版**红莲
# ------------------------------------------------------------
# 【出参】#rl_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 主手 + 副手都判 ★】右键消耗触发, 斧可能在副手(左手持斧时进度照样成立)。
# 【判据】custom_data 里 zx 含本装备 id **且** ol 等于本装备 id(见 overlimit/api/fit)。
# ============================================================

scoreboard players set #rl_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["red_lotus"],ol:"red_lotus"}] run scoreboard players set #rl_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["red_lotus"],ol:"red_lotus"}] run scoreboard players set #rl_ol zx.meta 1

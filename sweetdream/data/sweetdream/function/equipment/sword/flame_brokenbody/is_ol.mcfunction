# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/is_ol —— 手里这把是不是**超限版**
# ------------------------------------------------------------
# 【出参】#fb_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 主手 + 副手都判 ★】右键消耗触发, 剑可能在副手(左手持剑时进度照样成立)。
# 【判据】custom_data 里 zx 含本装备 id **且** ol 等于本装备 id ——
#   只看 ol 会认错别的超限武器(见 overlimit/api/fit)。
# ============================================================

scoreboard players set #fb_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["flame_brokenbody"],ol:"flame_brokenbody"}] run scoreboard players set #fb_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["flame_brokenbody"],ol:"flame_brokenbody"}] run scoreboard players set #fb_ol zx.meta 1

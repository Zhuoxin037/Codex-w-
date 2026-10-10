# ============================================================
# sweetdream:equipment/axe/charge/is_ol —— 手里这把是不是**超限版**超•负•荷
# ------------------------------------------------------------
# 【出参】#chg_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 主手 + 副手都判 ★】右键消耗触发, 斧可能在副手(左手持斧时进度照样成立)。
# 【判据】custom_data 里 zx 含本装备 id **且** ol 等于本装备 id(见 overlimit/api/fit)。
# 【谁用】cast ①'(拍施法快照 zx.chg_ol) / passive(主手持着就给迅捷Ⅱ)。
# ============================================================

scoreboard players set #chg_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["charge"],ol:"charge"}] run scoreboard players set #chg_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["charge"],ol:"charge"}] run scoreboard players set #chg_ol zx.meta 1

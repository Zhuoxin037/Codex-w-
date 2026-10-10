# ============================================================
# sweetdream:equipment/sword/shadow_blade/is_ol —— 手里这把是不是**超限版**
# ------------------------------------------------------------
# 【出参】#sb_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 主手 + 副手都判 ★】和基础版 kill 那条判据保持一致(见 kill ②): 影刃可能
#   拿在副手, 只判主手会让"左手超限影刃"按基础版结算。
# ============================================================

scoreboard players set #sb_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["shadow_blade"],ol:"shadow_blade"}] run scoreboard players set #sb_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["shadow_blade"],ol:"shadow_blade"}] run scoreboard players set #sb_ol zx.meta 1

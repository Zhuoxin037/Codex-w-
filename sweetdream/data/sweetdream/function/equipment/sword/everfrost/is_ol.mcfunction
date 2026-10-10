# ============================================================
# sweetdream:equipment/sword/everfrost/is_ol —— 手里这把是不是**超限版**永霜
# ------------------------------------------------------------
# 【出参】#ef_ol zx.meta = 1 / 0   【执行者】玩家
# 【★ 主手 + 副手都判 ★】主动技能是右键消耗触发的, 剑可能在副手(左手持剑时
#   进度照样成立), 只判主手会出现"左手拿超限永霜放技能却按基础版结算"。
# 【★ 超限标记长什么样 ★】敲过超限石的装备 custom_data 里多一个 `ol:"<装备id>"`
#   (见 overlimit/api/fit), 所以判据是 zx 含本装备 id **且** ol 等于本装备 id
#   —— 只看 ol 会认错别的超限武器。
# ============================================================

scoreboard players set #ef_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["everfrost"],ol:"everfrost"}] run scoreboard players set #ef_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["everfrost"],ol:"everfrost"}] run scoreboard players set #ef_ol zx.meta 1

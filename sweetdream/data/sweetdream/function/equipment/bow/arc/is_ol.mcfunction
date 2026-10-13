# ============================================================
# sweetdream:equipment/bow/arc/is_ol —— 「电弧」手里这把是不是超限版
# ------------------------------------------------------------
# 【谁调用它】arc/shot(离弦那一刻快照到玩家计分项 zx.arc_ol)
# 【出参】#arc_ol zx.meta: 1 = 主手这把是「超限·电弧」, 0 = 原版
# 【判据】主手物品的 custom_data 同时带 zx:["arc"] 与 ol:"arc"
#   (敲上超限后由 overlimit/api/fit + station/api/apply 写入 ol:"arc";
#    定义见 overlimit/def/load 的 oldef."arc")
# 【为什么要快照】命中回调(hook_victim)那次拿的是"中箭的生物", 不能现读射手的主手;
#   所以离弦时把结论拍进玩家的 zx.arc_ol, 命中时按它分流(同 sculk_echo 的 se.ol 口径)。
# ============================================================

scoreboard players set #arc_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["arc"],ol:"arc"}] run scoreboard players set #arc_ol zx.meta 1

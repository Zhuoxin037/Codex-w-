# ============================================================
# sweetdream:equipment/axe/skyvault/hit_go —— 被动主体: 给刚打中的那只叠一层「升痕」
# ------------------------------------------------------------
# 【执行者】动手的玩家
# ============================================================

function sweetdream:lib/victim
execute if entity @e[tag=zx.victim] run function sweetdream:equipment/axe/skyvault/mark
tag @e[tag=zx.victim] remove zx.victim

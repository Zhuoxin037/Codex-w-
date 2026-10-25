# ============================================================
# sweetdream:equipment/sword/way_back/lost —— 灯已不在（跨维度 / 被清掉）
# ------------------------------------------------------------
# 状态照清，但**不给返还**：设计原文"灯 20 秒后熄灭，240 魔力 + 40 秒冷却全损"，
# 灯提前丢失同理。清掉状态是为了让下一次右键能重新放灯（否则 zx.wb_on 卡在 1，
# 之后每次右键都走"回去"分支、永远找不到灯）。
# ============================================================
scoreboard players reset @s zx.wb_on
scoreboard players reset @s zx.wb_t
scoreboard players reset @s zx.wb_dmg
scoreboard players reset @s zx.wb_low
tellraw @s [{"text":"归途灯已不在，本次未返还任何生命值","color":"red"}]

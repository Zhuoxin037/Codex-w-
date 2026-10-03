# ============================================================
# sweetdream:debug/tg_mana —— /trigger zx.dbg_mana 的处理体
# ------------------------------------------------------------
# 【顺序很重要】先归零 -> 干活 -> 最后 enable(见 tg_stats 的说明)。
# 【补多少】走现成的 debug/recover_mana: 用 api/mana/consume 传 -1000,
#   也就是 +1000, 最后被上限夹住 —— 所以实际效果是"补满"。
#   想改成"固定 +N 不夹"得动 manacore 的 clamp, 那是另一回事了。
# ============================================================

scoreboard players set @s zx.dbg_mana 0
tellraw @s [{"text":"[调试] /trigger 收到: 回满魔力","color":"dark_gray"}]
function sweetdream:debug/recover_mana
scoreboard players enable @s zx.dbg_mana

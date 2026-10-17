# ============================================================
# sweetdream:equipment/armor/backlight/second —— 「回照」5 秒到期清理（每秒兜底）
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second → backlight/second
# 【为什么还要这个】on_cast 里判的是 "zx.bk_wd >= #now"，已经能正确处理过期；
#   这里只是把**过期值清成 0**，让观测镜/调试看到的"回照剩余"不会一直停在旧值。
#   （纯清理，不改任何行为。）
# ============================================================

execute as @a[scores={zx.bk_wd=1..}] if score @s zx.bk_wd < #now manacore.meta run scoreboard players set @s zx.bk_wd 0

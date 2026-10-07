# ============================================================
# sweetdream:equipment/staff/apocalypse/page_tick —— 每 4 秒换页
# ------------------------------------------------------------
# 【谁调用它】tick_go 第 ② 步(执行者 = 玩家)
# 【有页才消耗】页数 ap_n 是持久资产(跨施法保留), 没页就跳过。
# 【consume_page 做的事】整列左移: cur ← p1, p1 ← p2, p2 ← p3,
#   p3 清 0, 页数 -1 —— 之后 s+3 的灾示用的就是新页的魔力值。
# ============================================================

# ① 重置换页计时(下一个 4 秒)
scoreboard players set @s zx.ap_t4 4

# ② 有页 → 消耗一页
execute if score @s zx.ap_n matches 1.. run function sweetdream:equipment/staff/apocalypse/consume_page

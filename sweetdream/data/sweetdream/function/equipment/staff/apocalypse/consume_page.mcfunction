# ============================================================
# sweetdream:equipment/staff/apocalypse/consume_page —— 消耗一页「启示」
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑦ 步(施法时第一页) / page_tick(每 4 秒的后续页)
# 【整列左移】页按消耗顺序排队(p1 最先记的先消耗): cur ← p1, p1 ← p2,
#   p2 ← p3, p3 清 0, 页数 -1。调用前提 = zx.ap_n >= 1(调用方已判)。
# ============================================================

scoreboard players operation @s zx.ap_cur = @s zx.ap_p1
scoreboard players operation @s zx.ap_p1 = @s zx.ap_p2
scoreboard players operation @s zx.ap_p2 = @s zx.ap_p3
scoreboard players operation @s zx.ap_p3 = @s zx.ap_p4
scoreboard players set @s zx.ap_p4 0
scoreboard players remove @s zx.ap_n 1
function sweetdream:equipment/staff/apocalypse/visual/consume
execute at @s run playsound minecraft:block.note_block.chime player @s ~ ~ ~ 0.8 1.6

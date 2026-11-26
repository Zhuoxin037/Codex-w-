# ============================================================
# fallendream:equipment/bow/burst_dawn/shade_model_die —— 外观载体的收尸
# ------------------------------------------------------------
# 【谁调用它】shade_model 的两个判据(寿命到 / 掉下载具)
# 【执行者】item_display
# 【为什么先 reset 再 kill】计分项是按 UUID 记账的, kill 不会把它带走;
#   不 reset 的话反复施法会在计分板上堆一串再也用不到的 UUID 条目。
# ============================================================

scoreboard players reset @s zx.bd_mft
kill @s

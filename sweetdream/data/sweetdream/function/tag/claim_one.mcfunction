# ============================================================
# sweetdream:tag/claim_one —— 认领自己的图标(取编号层)
# ------------------------------------------------------------
# 【执行者】带 zx.tagged 的生物(也就是"还活着"的)
# ============================================================

execute store result storage zx:work ic.id int 1 run scoreboard players get @s zx.icon_id
function sweetdream:tag/claim_go with storage zx:work ic

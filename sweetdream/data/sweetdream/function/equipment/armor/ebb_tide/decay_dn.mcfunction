# ============================================================
# sweetdream:equipment/armor/ebb_tide/decay_dn —— 生物离开海浪: 每秒回落 10 个百分点
# ------------------------------------------------------------
# 【执行者】那只生物(@s)
# 【★ 文案(逐字)】"离开海浪后增益或减益将极速衰减。"
# 【★ 量化 = 每秒 -10 个百分点 ★】不是立刻清零(设计稿 §七 边界):
#   立刻清零会让"拉扯进出"完全没有手感。
# ============================================================

scoreboard players remove @s zx.et_e 10
execute if score @s zx.et_e matches ..0 run scoreboard players set @s zx.et_e 0
function sweetdream:equipment/armor/ebb_tide/speed_dn

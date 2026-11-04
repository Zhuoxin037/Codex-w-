# ============================================================
# sweetdream:equipment/staff/intone/one —— 单个追随者：只在我名下的那个才唱
# ------------------------------------------------------------
# 【执行者】追随者（marker）
# 【判据】反查主人 lib/u_by → 主人身上带 zx.in_owner（= 刚施法的那个玩家）
# ============================================================

tag @a[tag=zx.ub] remove zx.ub
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute if entity @a[tag=zx.ub,tag=zx.in_owner] at @s run function sweetdream:profession/singer/pulse

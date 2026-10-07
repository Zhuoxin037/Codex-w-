# ============================================================
# sweetdream:equipment/staff/gu_poison/gp_end —— 6 秒走完: 移除「噬心」+ 收尾
# ------------------------------------------------------------
# 【谁调用它】gp_tick 第 ④ 步; 【执行者】目标生物
# 【技能原文(lore 逐字)】…持续 6 秒。之后移除「噬心」。
# 【移除走统一入口】lib/mark_consume(让余烬/永恒的消耗被动收得到信号)。
# ============================================================

data modify storage zx:work a set value {target:"@s",mark:"shixin"}
function sweetdream:lib/mark_consume
tag @s remove zx.gp_tgt
particle minecraft:witch ~ ~1 ~ 0.4 0.6 0.4 0.05 12 normal

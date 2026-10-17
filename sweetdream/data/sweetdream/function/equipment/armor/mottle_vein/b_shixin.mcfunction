# ============================================================
# sweetdream:equipment/armor/mottle_vein/b_shixin —— 杂纹: 本轮消费过「噬心」
# ------------------------------------------------------------
# 【谁调用它】reward ③   【执行者】玩家
# 【技能原文】"若消耗了「噬心」则自身恢复 15% 最大生命值。"
# 【★ 上限读原版属性 ★】lib/heal 内部也用同一来源算临时上限, 同源才不会差出
#   "面板/属性不同步"的那一截(殓丝 on_hurt / 彼岸 heal 同款)。
# ============================================================

execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #mv_pct zx.meta 15
scoreboard players operation #heal_pt zx.meta *= #mv_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
function sweetdream:lib/heal

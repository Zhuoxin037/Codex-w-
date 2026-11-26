# ============================================================
# fallendream:equipment/armor/empty_camp/set_cd_tick —— 超限·空营：套装效果冷却每秒 -1 秒
# ------------------------------------------------------------
# 【文案】"8 格内没有敌对生物时，每秒恢复 1% 魔力值，自身套装效果冷却时间每秒额外 -1 秒。"
# 【★ 口径(待用户确认) ★】本包没有统一的"套装冷却"面板属性；能查到的、真正属于
#   **套装**的节流账本只有这 5 条（潮线/缝心×2/浅梦/残烛），这里对它们逐条 -20 刻。
#   单件节流（fh_cd / ss_cd / tw_cd / ns_cd / cc_cd / cr_cd…）**不**动 ——
#   那些文案写的是"该装备/该技能"，不是"套装效果"。
#   ★ 激活窗口(ns_set_end / cr_ol_end 等)是增益时长而不是冷却，减它会缩短增益，绝不碰。
# 【★ 先 add 0 建分再比 ★】分数不存在时比较恒假；减完还要夹回"不早于现在"，
#   免得下一秒把它判成负数、白给一次提前触发。
# ============================================================

scoreboard players add @s zx.tw_set_cd 0
execute if score @s zx.tw_set_cd > #now manacore.meta run scoreboard players remove @s zx.tw_set_cd 20
execute if score @s zx.tw_set_cd < #now manacore.meta run scoreboard players operation @s zx.tw_set_cd = #now manacore.meta

scoreboard players add @s zx.cr_knit_cd 0
execute if score @s zx.cr_knit_cd > #now manacore.meta run scoreboard players remove @s zx.cr_knit_cd 20
execute if score @s zx.cr_knit_cd < #now manacore.meta run scoreboard players operation @s zx.cr_knit_cd = #now manacore.meta

scoreboard players add @s zx.cr_amp_cd 0
execute if score @s zx.cr_amp_cd > #now manacore.meta run scoreboard players remove @s zx.cr_amp_cd 20
execute if score @s zx.cr_amp_cd < #now manacore.meta run scoreboard players operation @s zx.cr_amp_cd = #now manacore.meta

scoreboard players add @s zx.lp_set_cd 0
execute if score @s zx.lp_set_cd > #now manacore.meta run scoreboard players remove @s zx.lp_set_cd 20
execute if score @s zx.lp_set_cd < #now manacore.meta run scoreboard players operation @s zx.lp_set_cd = #now manacore.meta

scoreboard players add @s zx.cs_set_cd 0
execute if score @s zx.cs_set_cd > #now manacore.meta run scoreboard players remove @s zx.cs_set_cd 20
execute if score @s zx.cs_set_cd < #now manacore.meta run scoreboard players operation @s zx.cs_set_cd = #now manacore.meta

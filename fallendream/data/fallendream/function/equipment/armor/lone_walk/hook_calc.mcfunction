# @calc: indep — 套装「临敌」期间技能伤害 +10%（独立乘区）
# ============================================================
# fallendream:equipment/armor/lone_walk/hook_calc —— 「临敌」的 10% 独立乘区
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc（排在 lib/dmg_add_apply **之后**）
# 【执行者】施法者（玩家）
# 【★ 为什么只做独立乘区 ★】本件的另一段增伤（被动 +8%）**没有**"独立乘区"字样，
#   属加算 ⇒ 在 lone_walk/hook_add（apply 之前）里做。两件事必须分开挂在两个文件，
#   合并成一个文件必然有一边挂错位置而静默失效（见 hook_add 文件头的事故注）。
# 【★ 写法 ★】与 glimmer/hook_calc 逐字同源：r.damage ×1000 → mul_pct(×110) → ÷1000。
# 【★ 窗口判据 ★】zx.lw_lc = 「临敌」到期刻（set_lc 写 #now+80 = 4 秒），`> #now` 即生效中。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.lw_lc > #now manacore.meta run return 0

scoreboard players set #lwc zx.meta 0
execute store result score #lwc zx.meta run data get storage manacore:out r.damage 1000
scoreboard players set #lwk zx.meta 110
function manacore:internal/damage/mul_pct {src:"#lwc",mul:"#lwk",obj:"zx.meta"}
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta

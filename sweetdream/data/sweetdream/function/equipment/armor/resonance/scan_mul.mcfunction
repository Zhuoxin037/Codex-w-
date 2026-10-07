# ============================================================
# sweetdream:equipment/armor/resonance/scan_mul —— 面板: 共振的技伤加成折进三条通道
# ------------------------------------------------------------
# @panel: smul_mm,smul_atk,smul_oth
# 【执行者】玩家本人(@s)   【读】api/formation/count
# 【出参】① 把 10n(百分点)写进**加算池** zx:work add 的三条通道;
#        ② 给 zx.meta #res_pct 写"倍率 ×100"(100 + 10n; 100 = 没加), stats 用它
#           决定要不要显示"共振：每术阵 +10%，已并入上面三条通道"那行灰字。
# 【★ 不再自己乘 smul_***★(2026-10-06 改)】
#   加算的正确口径是"先合并、再乘一次" —— 池子由 lib/skill_mul/scan 统一清空、
#   lib/skill_mul/padd_apply 统一折入。这里只负责"我贡献 10n"。
#   以前是直接乘 smul_*, 和漫步冥河(+30%)叠起来面板会显示 ×1.43(实伤只有 ×1.40)。
# 【为什么三条通道都写】文案"技能的伤害 +10%"不挑口径 ⇒ 三条都贡献, 面板三行都涨。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
execute store result score #n zx.meta run data get storage manacore:out r.count
execute unless score #n zx.meta matches 1.. run return 0

# #pct = 10n(百分点) —— 它同时是"要贡献的值"和"灰字倍率"的来源
scoreboard players set #pct zx.meta 0
scoreboard players operation #pct zx.meta = #n zx.meta
scoreboard players operation #pct zx.meta *= #10 zx.meta

# stats 用: #res_pct = 100 + 10n(倍率 ×100)
scoreboard players set #res_pct zx.meta 100
scoreboard players operation #res_pct zx.meta += #pct zx.meta

# 贡献三条通道
execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put
data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put
data modify storage zx:work put.ch set value "oth"
function sweetdream:lib/dmg_add_put with storage zx:work put

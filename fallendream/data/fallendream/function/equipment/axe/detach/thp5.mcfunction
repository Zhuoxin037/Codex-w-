# ============================================================
# fallendream:equipment/axe/detach/thp5 —— 15% 最大生命的临时生命，持续 5 秒
# ------------------------------------------------------------
# 【谁调用它】detach/hit_go/victim_body ③（twin/enter 之后）
# 【执行者】玩家（已是同生体）
# 【单位】lib/thp/add 的 #thp_v 是**点数**；lib/max_health_score 的 #max_hp 是毫点
#   ⇒ 先 ÷1000 成点，再 ×15÷100。
# 【★ 时长只往上抬 ★】lib/thp/add 统一给 60 秒，而文案要 5 秒。直接覆盖会把玩家身上
#   更长的临时生命（溢流/蓄意）一起掐掉 —— 取较大值：短的那份压到 5 秒，长的不动。
# 【★ 为什么不用吸收效果自带时长 ★】本包的临时生命账本只有一个（lib/thp），
#   另开一路 absorption 会和它的 max_absorption 修饰符打架（见 lib/thp/set 文件头）。
# ============================================================

function fallendream:lib/max_health_score
scoreboard players operation #dto_thp zx.meta = #max_hp zx.meta
scoreboard players operation #dto_thp zx.meta /= #1000 zx.meta
scoreboard players operation #dto_thp zx.meta *= #15 zx.meta
scoreboard players operation #dto_thp zx.meta /= #100 zx.meta

scoreboard players operation #thp_v zx.meta = #dto_thp zx.meta
execute if score #thp_v zx.meta matches 1.. run function fallendream:lib/thp/add

scoreboard players operation #dto_t5 zx.meta = #now manacore.meta
scoreboard players add #dto_t5 zx.meta 100
execute if score #thp_v zx.meta matches 1.. if score @s zx.thp_end < #dto_t5 zx.meta run scoreboard players operation @s zx.thp_end = #dto_t5 zx.meta

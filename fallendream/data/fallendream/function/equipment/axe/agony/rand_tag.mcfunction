# ============================================================
# fallendream:equipment/axe/agony/rand_tag —— 苦痛·超限：给死亡 AoE 的受害者各发一个随机标签
# ------------------------------------------------------------
# 【谁调用它】one ⑥（超限那一轮，且仅在死亡分支）
# 【执行者】死者（尸体状态）—— 只用来给 lib/rnd 与 tag/mark 提供位置上下文
# 【目标】@e[tag=zx.ag_dead] = 刚才 AoE 打到的全部生物（one ⑥ 打完伤害后才清标签）
# 【"随机标签"= 包内既有五种状态标签】流火 / 夜火 / 噬心 / 渊海 / 白昼梦
#   —— 杂纹超限的"附加一个随机标签"用的是同一套词表，别另开第六种。
# 【★ 整批共用一次抽签 ★】文案是"对其 2 格内的全部生物…附加一个随机标签"，
#   一次 AoE 抽一个，圈内同生共死；逐只各抽一次会让同一圈里五颜六色，不是描述的画面。
# ============================================================

function fallendream:lib/rnd
scoreboard players operation #ag_r zx.meta = #rnd zx.meta
scoreboard players operation #ag_r zx.meta %= #5 zx.meta

execute if score #ag_r zx.meta matches 0 run function fallendream:tag/mark {target:"@e[tag=zx.ag_dead]",mark:"liuhuo"}
execute if score #ag_r zx.meta matches 1 run function fallendream:tag/mark {target:"@e[tag=zx.ag_dead]",mark:"yehuo"}
execute if score #ag_r zx.meta matches 2 run function fallendream:tag/mark {target:"@e[tag=zx.ag_dead]",mark:"shixin"}
execute if score #ag_r zx.meta matches 3 run function fallendream:tag/mark {target:"@e[tag=zx.ag_dead]",mark:"yuanhai"}
execute if score #ag_r zx.meta matches 4 run function fallendream:tag/mark {target:"@e[tag=zx.ag_dead]",mark:"dream"}

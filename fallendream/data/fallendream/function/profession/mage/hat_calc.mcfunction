function fallendream:profession/mage/tally
# 超限·鹰羽帽(2026-11-22): 独立乘区窗口内不再往加算池写 —— 那一份改由
#   equipment/armor/eagle_hat/hook_indep 乘在 mm 段上。两条路必须互斥, 否则
#   同一份 10+6X% 会被加算池和独立乘区各算一次。
execute if score @s zx.eh_indep_end > #now manacore.meta run return 0
scoreboard players operation #jhatpct zx.meta = #jorbs zx.meta
# 10+5X%(基础) / 10+6X%(超限)。★ 不要复用 #j5 ★ —— 它是 core/load 里的全局常量,
#   bloom_pulse / draw / book / twin/reflect 都在用, 改它等于污染别的功能。
scoreboard players set #jhat_k zx.meta 5
execute if items entity @s armor.head *[custom_data~{zx:["eagle_hat"],ol:"eagle_hat"}] run scoreboard players set #jhat_k zx.meta 6
scoreboard players operation #jhatpct zx.meta *= #jhat_k zx.meta
scoreboard players add #jhatpct zx.meta 10
execute store result storage zx:work put.pct int 1 run scoreboard players get #jhatpct zx.meta
data modify storage zx:work put.ch set value "mm"
function fallendream:lib/dmg_add_put with storage zx:work put

# ============================================================
# sweetdream:upgrade/api/dmg_held —— 主手武器升级里的"技能伤害 +X%"折进加算池
# ------------------------------------------------------------
# @calc: add     ← 加算型 hook: 只往池子里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 排在 lib/dmg_add_clear 之后、
#   lib/dmg_add_apply **之前**(顺序由 check 规则 dmgord 锁死)。
# 【★ 执行者就是施法者本人 ★】见 resonance/hook_calc 顶部说明 —— function 不换 @s,
#   所以这里能直接读 SelectedItem。非玩家(法球/箭/命令方块)先退出。
# 【它管的是谁】主手武器的升级定义表 dmg 字段(愿景 α/β/Ω = +10/20/30%)。
#   🔸 副作用(有意为之): 老的「锐利」(+10%, 剑) 也从此**真正生效**了 ——
#      它的文案本来就是"伤害 +10%", 之前一直没接线(设计文档 §7 记的欠账)。
#      「高效」的 mana(-10%) 仍然没接线 —— 那是"魔力消耗", 不在伤害链上,
#      要接得改每个技能扣蓝的口径, 本批不动。
# 【为什么三条通道都写】文案是"技能伤害 +X%", 不挑口径。写满三条之后由
#   lib/dmg_add_apply 只取"本次技能真正用到的那条", 等价于三条各 ×(1+X%)。
# 【为什么不用独立乘区】本包口径: 没标"独立乘区"的一律加算(见 lib/dmg_add_clear)。
# 【为什么调 bonus_held 而不是自己读物品】升级的解析(同系取最高 tier / 乘区累加)
#   全在 bonus_held 里, 自己读会漏掉分级链条, 迟早和别的消费点对不上。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0

function sweetdream:upgrade/api/bonus_held

scoreboard players set #pct zx.meta 0
execute store result score #pct zx.meta run data get storage zx:out r.dmg 100
# 一份贡献都没有(没敲升级 / 敲的都是没 dmg 的) -> 走人, 不白绕三次定点乘除
execute unless score #pct zx.meta matches 1.. run return 0

execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put
data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put
data modify storage zx:work put.ch set value "oth"
function sweetdream:lib/dmg_add_put with storage zx:work put

# ============================================================
# fallendream:equipment/sword/profane/hit —— 剖心（下界剑 · 普攻被动）
# ------------------------------------------------------------
# 【触发】玩家普攻命中（advancement player_hurt_entity + is_player_attack）
# 【技能原文】
#   魔力 80 · 伤害 1
#   未超限: "每次普攻命中附有「噬心」的生物时，使其「噬心」的剩余时长延长 2 秒（最多 18 秒），
#    并额外造成相当于自身基础攻击力的伤害。该效果 5 秒内最多触发一次。"
#   超限·剖心(2026-10-23 批 K2): 延长 2 -> **3 秒**、上限 18 -> **24 秒**;
#    其余(额外伤害 ×1、5 秒限频)不变 —— 原文没提限频, 就按"只改说到的部分"。
# 【为什么先判满蓄力】包内所有"普攻附带"件（秤星 / 归息 / 回旋）都先走 lib/atk_charge：
#   不满蓄力的一下不算"命中"，否则连点能无限延长噬心。
# 【上限怎么夹】噬心施加时满值 18（tag/mark_one），但**超限的延长能顶到 24** ——
#   "延长"不等于"重新施加", 所以上限不复用 mark_one 的 18, 而是 hit 自己的 #pf_cap。
# 【限频】zx.pf_poke = 下次可触发的**绝对刻**（#now + 100）。没有分数时比较失败，
#   正好等于"从没触发过"，不需要额外初始化。
# ============================================================
advancement revoke @s only fallendream:equipment/sword/profane_hit

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["profane"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["profane"]}] run return 0

# 【超限分档 2026-10-23 批 K2】未超限 +2 秒 / 上限 18 -> 超限 +3 秒 / 上限 24
#   ★ "延长"能超过施加时的满值(18) —— 超限下上限才是 24, 所以不能沿用 mark_one 的 18。
#   ★ #pf_ol 只在这一次函数调用里"设 + 用", 不跨刻, 没有串号窗口。
scoreboard players set #pf_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["profane"],ol:"profane"}] run scoreboard players set #pf_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["profane"],ol:"profane"}] run scoreboard players set #pf_ol zx.meta 1

scoreboard players set #pf_add zx.meta 2
scoreboard players set #pf_cap zx.meta 18
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #pf_add zx.meta 3
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #pf_cap zx.meta 24

function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/sword/profane/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]

# ============================================================
# fallendream:equipment/armor/last_breath/hit —— 归息: 近战命中后消耗状态换回复
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/last_breath_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +140。普通近战命中了附有「渊海」或「噬心」且
#   仍存活的生物后，消耗其一种效果，并为自身恢复 6 点生命值及 20 点魔力值
#   （优先消耗「渊海」）。该效果 8 秒内不可再次触发，自身生命值为满时不触发。
# 【★ "且仍存活" 是天然满足的 ★】进度在**伤害打完之后**才抛；目标若被这一下打死，
#   它已从世界移除 ⇒ 身上那条标签也就没了 ⇒ 下面挑不出状态、直接收工。
# 【★ 消耗必须标 src:"equip" ★】这是**装备被动**顺手消耗的，不是"技能消耗" ——
#   不标的话，穿回潮扣/烛跬时一次平A会白蹭到那两件的"技能消耗"效果。
#
# 【★ 分级诊断锚(2026-10-15 加) ★】这条链上有 6 个**静默**断点，断在哪一级的表现
#   都是"什么都没发生、零日志"。所以每"通过一级"就把 #lb_d1..d8 里对应的那个 +1，
#   用 /function fallendream:debug/lb_probe 读：**哪一级计数明显小于上一级，就断在那里**。
#   d1=进度触发 · d2=蓄力过 · d3=穿着过 · d4=定位到目标 · d5=非满血 · d6=冷却就绪 ·
#   d7=目标带渊海/噬心 · d8=真的兑现了。锚只加在"假玩家"上，不改任何行为。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/last_breath_hit
scoreboard players add #lb_d1 zx.meta 1

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
scoreboard players add #lb_d2 zx.meta 1

# ① 没穿归息就没这事（胸甲）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["last_breath"]}] run return 0
scoreboard players add #lb_d3 zx.meta 1

# ② 定位"刚才这一下平A打的是哪一只"（lib/victim：last_hurt_by_player + HurtTime 收窄）
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/armor/last_breath/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]

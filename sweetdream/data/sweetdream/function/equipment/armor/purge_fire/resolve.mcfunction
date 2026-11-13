# ============================================================
# sweetdream:equipment/armor/purge_fire/resolve —— 涤火：消耗 / 恢复 / 加成
# ------------------------------------------------------------
# 【谁调用它】purge_fire/hurt ⑤（execute at @s run function ...）
# 【执行者】受伤的玩家   【执行位置】玩家所在（由调用方 at @s 保证）
# 【入参】#pf_both zx.meta = 1 表示攻击者同时带「夜火」（40% 档），0 表示 10% 档
# ============================================================

# ① 消耗攻击者身上的「流火」；第二档再消耗「夜火」
#   ★ target 用自家标签 zx.pf_src 定位，摘掉状态标签后仍能找到它
#   ★ src:"equip" = 装备被动自己顺手消耗（不算"技能消耗"，别触发回潮扣/烛跬那类）
data modify storage zx:work a set value {target:"@e[tag=zx.pf_src,limit=1]",mark:"liuhuo",by:"@s",src:"equip"}
function sweetdream:lib/mark_consume
data modify storage zx:work a set value {target:"@e[tag=zx.pf_src,limit=1]",mark:"yehuo",by:"@s",src:"equip"}
execute if score #pf_both zx.meta matches 1 run function sweetdream:lib/mark_consume

# ② 恢复自身 10% / 40% 生命值
#   #max_hp 是毫点(×1000) → mul_permille 乘 100‰ / 400‰ → 仍是毫点 → /1000 取整点
#   → #heal_pt zx.meta = 整点数 → lib/heal（执行者必须 = 被治疗玩家）
function sweetdream:lib/max_health_score
scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players set #mp_mul zx.meta 100
execute if score #pf_both zx.meta matches 1 run scoreboard players set #mp_mul zx.meta 400
function sweetdream:lib/math/mul_permille
scoreboard players operation #heal_pt zx.meta = #mp_out zx.meta
scoreboard players operation #heal_pt zx.meta /= #1000 zx.meta
function sweetdream:lib/heal

# ③ 第二档额外：自身基础攻击力 +20%，持续 5 秒
execute if score #pf_both zx.meta matches 1 run function sweetdream:equipment/armor/purge_fire/buff

# ============================================================
# fallendream:equipment/armor/purge_fire/resolve —— 涤火：消耗 / 恢复 / 加成
# ------------------------------------------------------------
# 【谁调用它】purge_fire/hurt ⑤（execute at @s run function ...）
# 【执行者】受伤的玩家   【执行位置】玩家所在（由调用方 at @s 保证）
# 【入参】#pf_both zx.meta = 1 表示攻击者同时带「夜火」（第二档），0 表示第一档
#         #pf_ol   zx.meta = 1 表示穿的是超限·涤火（由 hurt ①.5 定下）
# ============================================================

# ① 消耗攻击者身上的「流火」；第二档再消耗「夜火」
#   ★ target 用自家标签 zx.pf_src 定位，摘掉状态标签后仍能找到它
#   ★ src:"equip" = 装备被动自己顺手消耗（不算"技能消耗"，别触发回潮扣/烛跬那类）
data modify storage zx:work a set value {target:"@e[tag=zx.pf_src,limit=1]",mark:"liuhuo",by:"@s",src:"equip"}
function fallendream:lib/mark_consume
data modify storage zx:work a set value {target:"@e[tag=zx.pf_src,limit=1]",mark:"yehuo",by:"@s",src:"equip"}
execute if score #pf_both zx.meta matches 1 run function fallendream:lib/mark_consume

# ② 恢复自身生命值
#   基础: 10% / 第二档 40%   超限: 12% / 第二档 50%
#   #max_hp 是毫点(×1000) → mul_permille 乘千分比 → 仍是毫点 → /1000 取整点
#   → #heal_pt zx.meta = 整点数 → lib/heal（执行者必须 = 被治疗玩家）
function fallendream:lib/max_health_score
scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players set #mp_mul zx.meta 100
execute if score #pf_both zx.meta matches 1 run scoreboard players set #mp_mul zx.meta 400
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #mp_mul zx.meta 120
execute if score #pf_ol zx.meta matches 1 if score #pf_both zx.meta matches 1 run scoreboard players set #mp_mul zx.meta 500
function fallendream:lib/math/mul_permille
scoreboard players operation #heal_pt zx.meta = #mp_out zx.meta
scoreboard players operation #heal_pt zx.meta /= #1000 zx.meta
function fallendream:lib/heal

# ③ 第二档额外：自身基础攻击力加成（基础 +20%/5 秒，超限 +30%/8 秒）
execute if score #pf_both zx.meta matches 1 run function fallendream:equipment/armor/purge_fire/buff

# ④ 超限第三段：通过**本件**同时消耗掉「流火」+「夜火」的生物 -> 开 8 秒观察窗口
#   【文案(逐字)】"通过该装备消耗了「流火」和「夜火」的生物若在 8 秒内被附加了
#     「流火」，则额外附加「夜火」并使其在该「流火」或「夜火」的持续时间内受到的
#     伤害 +20%…"
#   ★ 只认第二档（两件都消耗了）★ 第一档只吃掉「流火」, 不满足文案门槛。
#   ★ 兑现点是 purge_fire/link_tick（每秒扫 @e[tag=zx.pf_watch]）★
execute if score #pf_ol zx.meta matches 1 if score #pf_both zx.meta matches 1 run tag @e[tag=zx.pf_src,distance=0..] add zx.pf_watch
execute if score #pf_ol zx.meta matches 1 if score #pf_both zx.meta matches 1 run scoreboard players operation @e[tag=zx.pf_src,distance=0..] zx.pf_w_end = #now manacore.meta
execute if score #pf_ol zx.meta matches 1 if score #pf_both zx.meta matches 1 run scoreboard players add @e[tag=zx.pf_src,distance=0..] zx.pf_w_end 160

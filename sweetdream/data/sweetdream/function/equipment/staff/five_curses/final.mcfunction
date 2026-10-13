# ============================================================
# sweetdream:equipment/staff/five_curses/final —— 「终世」结算(造成记录伤害的 N%)
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = 目标)
# 【入参】#fcv_pct zx.meta = 结算百分比(30 = 终世默认的 30% / 80 = 主动强化的 80%)
#   ★ 为什么用假玩家而不是宏参数: 调用方在"12 格内全体"的循环里逐个调本函数,
#     同一个百分比不会变, 假玩家够用; 走宏反而要给每次调用都绑一次 storage。
# 【文案】终世: 对其造成记录伤害的 30% **真实伤害**, 之后清除「世咒」。
#   主动技能把已在第五世的目标"立即结算终世", 比例由 30% 提高到 80%。
# 【定点】zx.fcv_rec 记的是"伤害 ×1000"; 乘百分比再除 100 ⇒ 结果仍是 ×1000,
#   写回 double 时用 scale 0.001 还原。
#   ★ 计分板是 int32: rec × pct 可能很大, 但真实量级(伤害几百 × 1000 × 80)远不到
#     2.1e9, 不会回绕 —— 若以后出现极端数值, 照 vuln_tag 的 R05 做法加钳位。
# 【为什么用真实伤害】文案写死"真实伤害", 对应 damage_type sweetdream:true_damage
#   (无视护甲); 它同样会吃到「噬心」的 +15%(那是对真实伤害的通用易伤, 属预期)。
# 【归属】用落咒时记下的 zx.fcv_u0..u3, 保证击杀算在**施法者**头上。
# ============================================================

# ① 伤害 = 记录伤害 × pct / 100(单位仍是 ×1000)
scoreboard players operation #fcv_d zx.meta = @s zx.fcv_rec
scoreboard players operation #fcv_d zx.meta *= #fcv_pct zx.meta
scoreboard players operation #fcv_d zx.meta /= #100 zx.meta

# ② 打出真实伤害(带施法者归属)
data modify storage zx:work a set value {target:"@s",damage:0.0,type:"sweetdream:true_damage",u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work a.damage double 0.001 run scoreboard players get #fcv_d zx.meta
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s zx.fcv_u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s zx.fcv_u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s zx.fcv_u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s zx.fcv_u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 表现
execute at @s run particle minecraft:damage_indicator ~ ~1 ~ 0.4 0.6 0.4 0.02 14 normal
execute at @s run particle minecraft:soul ~ ~1 ~ 0.3 0.5 0.3 0.0 10 normal

# ④ 清除「世咒」(层数 / 记录 / 计时 / 易伤标签 / 破甲 modifier)
function sweetdream:equipment/staff/five_curses/clear

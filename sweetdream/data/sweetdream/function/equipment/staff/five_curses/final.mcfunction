# ============================================================
# sweetdream:equipment/staff/five_curses/final —— 「终世」结算(造成记录伤害的 N%)
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = 目标)
# 【入参】**目标身上的 zx.fcv_pct** = 结算百分比(30 = 终世默认 / 40 = 超限·终世 /
#   80 = 主动强化 / 100 = 超限·主动)
#   ★ 2026-10-23 批 K9 改成"记在目标身上": 原来用全局假名 #fcv_pct 由调用方在调用前
#     set —— 它是**全局**的, 同一刻"先放主动(80)再普攻收尾(30)"会串成按 80% 结算;
#     更根本的问题是**自然到期**那条路(second)压根拿不到施法者, 只能靠目标身上的记录。
#     现在落咒时(curse_step ⓪.5)就把比例拍进目标, 主动结算前由 skill 覆盖成 80/100,
#     本函数只读目标自己那份 —— 每一份世咒各记各的, 天然不串。
#   ★ 读不到(老存档/异常)时按 **30** 兜底 = 原版行为。
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
scoreboard players set #fcv_pct zx.meta 30
execute if score @s zx.fcv_pct matches 1.. run scoreboard players operation #fcv_pct zx.meta = @s zx.fcv_pct
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

# ============================================================
# sweetdream:equipment/armor/crimson_seam/set_true_hit —— 缝心: 兑现「绯结」把真伤 +15%
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段)
# 【执行者】被打的那一只（@s = 目标）   【出参】改写 zx:work a.num / a.damage / a.num_str
# 【文案(套装段 逐字)】对原本附有「噬心」的目标造成真实伤害时，若有「绯结」则消耗
#   1 层并使这一段真实伤害提高 15%（独立乘区），并获得 2 秒抗性提升Ⅰ。
#   该强化 5 秒内最多触发一次。
# 【★ 排在 deal **之前** ★】"这一段真实伤害提高 15%"= 改这一下要打出去多少，
#   必须在 internal/damage/deal 之前把 a.num 写好。
# 【★ 只吃**真伤**且目标带噬心 ★】判据由 internal/damage/one 给出(与殓丝同条件)。
# 【★ 与燧行套装(smoke_step/set_burn)结构完全同款 ★】都是"反查施法者 → 在玩家
#   上下文里判套装/资源 → 回来把这个目标这一下的 a.num 乘上去"。区别只是乘区与前置条件。
# 【★ 不折面板 ★】理由同燧行: 生效与否取决于"**目标**是否带噬心 / 当前有没有绯结",
#   面板表达不了 (绯结层数面板判得了, 但目标条件判不了) ⇒ 宁少显示不多显示。
# ============================================================

# ⓪ 入参有东西可改吗
execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

# ① 施法者还在线吗
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 施法者侧的判定与动作（穿齐 / 5 秒节流 / 有绯结 / 消耗 1 层 / 2 秒抗性Ⅰ）
#    —— 走一个叶子件, 它把结果写进 #cr_ok
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/crimson_seam/amp_go
execute unless score #cr_ok zx.meta matches 1 run return 0

# ③ 伤害 ×1.15（独立乘区 = 乘在三条通道求和之后；#115 已在 core/load 注册）
scoreboard players set #crv zx.meta 0
execute if data storage zx:work a.num store result score #crv zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #crv zx.meta run data get storage zx:work a.damage 1000

#    【R05 整数上界保护】#crv 是"伤害 ×1000", 下一步 ×115 —— int32 会回绕,
#      所以钳到 INT32_MAX ÷ 115。常态(伤害 ≤ 约 1.8 万)一行都不受影响。
#      口径与 vuln_tag / stg_mul / set_burn 一致。
scoreboard players set #crv_cap zx.meta 2147483647
scoreboard players operation #crv_cap zx.meta /= #115 zx.meta
execute if score #crv zx.meta > #crv_cap zx.meta run scoreboard players operation #crv zx.meta = #crv_cap zx.meta

scoreboard players operation #crv zx.meta *= #115 zx.meta
scoreboard players operation #crv zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #crv zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num

# ④ 重新生成纯数字字符串（交给 internal/damage/deal 去打）
function sweetdream:lib/num/plain

# ⑤ 表现（在**施法者**身上放）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute at @a[tag=zx.ub,limit=1] run particle minecraft:crit ~ ~1 ~ 0.4 0.5 0.4 0.05 12 normal

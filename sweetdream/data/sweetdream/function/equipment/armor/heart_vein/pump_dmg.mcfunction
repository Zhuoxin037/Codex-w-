# ============================================================
# sweetdream:equipment/armor/heart_vein/pump_dmg —— 按"最大生命值 × mul‰"打一次伤害
# ------------------------------------------------------------
# 【执行者】带「泵动」的那只生物
# 【宏参数】zx:work hv {mul, u0..u3}
#   · mul = 50 ⇒ ×0.05（移动一格） / 80 ⇒ ×0.08（泵动中再被消耗噬心）
# 【文案口径】泵动的这两笔伤害文案只写"相当于其最大生命值 × N", **没写真实伤害**
#   ⇒ 走 sweetdream:skill（技能伤害）。这样它照常吃夜火/噬心那类受击侧乘区,
#   也照常进账本、能触发下面的吸血。（若日后裁定改成真伤, 只改这一行的 type。）
# 【★ 为什么必须有归属 ★】不带 u0..u3 的话这一笔是无归属伤害: 不进玩家账本、
#   不吃任何乘区、吸血也找不到人 ⇒ 文案后半句"自身会恢复…"整个落空。
# 【×1000 定点】lib/max_health_score 出参 #max_hp = 最大生命 ×1000;
#   damage ×1000 = #max_hp × mul ÷ 1000 ⇒ 最后 `double 0.001` 还原。
# 【R05 上界】先算"最大生命的上限"再夹, 不能先除后乘（会丢精度）。
# ============================================================

# ① 最大生命值（×1000）
function sweetdream:lib/max_health_score
scoreboard players operation #hv_d zx.meta = #max_hp zx.meta

# ② R05: 动态上界 = INT32_MAX ÷ mul, 超过就夹住
$scoreboard players set #hv_mul zx.meta $(mul)
scoreboard players set #hv_cap zx.meta 2147483647
scoreboard players operation #hv_cap zx.meta /= #hv_mul zx.meta
execute if score #hv_d zx.meta > #hv_cap zx.meta run scoreboard players operation #hv_d zx.meta = #hv_cap zx.meta

# ③ × mul ÷ 1000 ⇒ damage ×1000
scoreboard players operation #hv_d zx.meta *= #hv_mul zx.meta
scoreboard players operation #hv_d zx.meta /= #1000 zx.meta

# ④ 投递（a 是全包伤害入口的标准节点）
execute store result storage zx:work hv.num double 0.001 run scoreboard players get #hv_d zx.meta
$data modify storage zx:work a set value {target:"@s",damage:0.0,type:"sweetdream:skill",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
data modify storage zx:work a.damage set from storage zx:work hv.num
data modify storage zx:work a.num set from storage zx:work hv.num
function sweetdream:lib/num/plain
execute unless data storage zx:work hv_heal_stack run data modify storage zx:work hv_heal_stack set value []
$data modify storage zx:work hv_heal_stack append value {hp:0,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute store result storage zx:work hv_heal_stack[-1].hp int 1 run data get entity @s Health 1000
function sweetdream:internal/damage/with_from with storage zx:work a
function sweetdream:equipment/armor/heart_vein/lifesteal with storage zx:work hv_heal_stack[-1]
data remove storage zx:work hv_heal_stack[-1]

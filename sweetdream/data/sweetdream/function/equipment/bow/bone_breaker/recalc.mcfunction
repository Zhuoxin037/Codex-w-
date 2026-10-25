# ============================================================
# sweetdream:equipment/bow/bone_breaker/recalc —— 算「基础攻击力 ×0.3」
# ------------------------------------------------------------
# 【入参】zx:work bbk.uid(玩家 UUID 文本)
# 【出参】zx:work bbk.dmg1000(整数, = 伤害 ×1000)
# 【谁调用它】shot ④(召唤前算一次) / blade_tick(每 20 刻跟着面板重算一次)
# 【★ 为什么只认 stats/get 的 base_attack ★】「基础攻击力」有两个口径:
#   `attribute attack_damage get` 含手持武器, manacore 的 base_attack 不含
#   (默认 5)。本包"基础攻击力"一律走后者(MEMORY 环境段)。
# 【★ ×1000 定点 ★】计分项只有整数 ⇒ 先 ×1000 再算, 投递时 `double 0.001` 还原。
#   `data get ... 1000` 会把 double 乘 1000 再取整, 精度够这一档用。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:work bbk.uid
function manacore:api/stats/get

scoreboard players set #bb_d zx.meta 0
execute if data storage manacore:out r.value store result score #bb_d zx.meta run data get storage manacore:out r.value 1000
# 【★ R05 整数上界保护 ★】#bb_d 此刻是 ×1000 定点, 下一步要 ×3。计分板是 int32,
#   越过 2,147,483,647 会回绕成负数(不报错)。这里补一道动态上限 INT32_MAX ÷ 3;
#   基础攻击力常态远不到那个量级, 一行都不受影响。
scoreboard players set #bb_cap zx.meta 2147483647
scoreboard players operation #bb_cap zx.meta /= #3 zx.meta
execute if score #bb_d zx.meta > #bb_cap zx.meta run scoreboard players operation #bb_d zx.meta = #bb_cap zx.meta
scoreboard players operation #bb_d zx.meta *= #3 zx.meta
scoreboard players operation #bb_d zx.meta /= #10 zx.meta
execute store result storage zx:work bbk.dmg1000 int 1 run scoreboard players get #bb_d zx.meta

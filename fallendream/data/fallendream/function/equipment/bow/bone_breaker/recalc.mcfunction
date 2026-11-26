# ============================================================
# fallendream:equipment/bow/bone_breaker/recalc —— 算「基础攻击力 ×0.3(原版) / ×0.5(超限)」
# ------------------------------------------------------------
# 【入参】zx:work bbk.uid(玩家 UUID 文本) + @s 的 zx.bb_ol(0 原版 / 1 超限)
#   ★ @s 的 bb_ol: shot 里是**玩家**(召唤前算一次), blade_tick 里是**刀刃**本身
#     (blade_new 生成时从 bbk.ol 抄进来的) —— 两处同名不同实体, 语义一致。
# 【出参】zx:work bbk.base1000 = 基础攻击力 ×1000(给"累计 6 次"的 ×3 真伤用)
#         zx:work bbk.dmg1000  = 这一把刀每刻的伤害 ×1000
# 【谁调用它】shot(召唤前算一次) / blade_tick(每 20 刻跟着面板重算一次) / again(追加刀刃时)
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

# ① 原样的「基础攻击力 ×1000」先留在 storage 里 —— 累计 6 次的 ×3 真伤要它
execute store result storage zx:work bbk.base1000 int 1 run scoreboard players get #bb_d zx.meta

# ② 倍率分档: 原版 3/10(×0.3) / 超限 5/10(×0.5)
scoreboard players add @s zx.bb_ol 0
scoreboard players set #bb_k zx.meta 3
execute if score @s zx.bb_ol matches 1 run scoreboard players set #bb_k zx.meta 5

# 【★ R05 整数上界保护 ★】#bb_d 此刻是 ×1000 定点, 下一步要 ×#bb_k。计分板是 int32,
#   越过 2,147,483,647 会回绕成负数(不报错)。这里补一道动态上限 INT32_MAX ÷ #bb_k;
#   基础攻击力常态远不到那个量级, 一行都不受影响。
scoreboard players set #bb_cap zx.meta 2147483647
execute if score #bb_k zx.meta matches 1.. run scoreboard players operation #bb_cap zx.meta /= #bb_k zx.meta
execute if score #bb_d zx.meta > #bb_cap zx.meta run scoreboard players operation #bb_d zx.meta = #bb_cap zx.meta
scoreboard players operation #bb_d zx.meta *= #bb_k zx.meta
scoreboard players operation #bb_d zx.meta /= #10 zx.meta
execute store result storage zx:work bbk.dmg1000 int 1 run scoreboard players get #bb_d zx.meta

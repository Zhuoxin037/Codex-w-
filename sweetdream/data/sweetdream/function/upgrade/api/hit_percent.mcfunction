# ============================================================
# sweetdream:upgrade/api/hit_percent —— 把"最大魔力的 x%"算进本次回魔
# ------------------------------------------------------------
# 【入参】#up_pct = 百分数 ×100(1.5% -> 150)   【出参】累加进 #up_gain
#
# 【★ 单位链 —— 全包最容易差 100 倍的地方, 动之前先把这条数一遍 ★】
#     定义表 mhp      = 1.5   (百分数本身, 就是文案里的"1.5%")
#   -> r.mhp  = 1.5   (bonus_held: #up_mhp(150) ×0.01 存成 double)
#   -> #up_pct = 150  (on_hit: `data get storage zx:out r.mhp 100`)
#   -> 本次回魔 = 最大魔力 × #up_pct ÷ 10000
#   ★ 必须除 10000, 不是 100 ★ —— 因为 #up_pct 已经是"百分数 ×100"(单位为 0.01%),
#     再补一个 /100 才是百分比。只除 #100 会变成"最大魔力 × 1.5"= **150%**, 打一下
#     直接回满(2026-10-04 用户报的就是这个, 已修)。
#
# 【为什么先归零再 store】读不到(还没初始化面板)时 store 不执行, 分数会留着上一次的值
#   —— 那就会按别人的最大魔力回魔。
# 【取整】先加半个分母(#5000)再除 = 四舍五入(1.5% of 300 = 4.5 -> 5); 不补这一下
#   会一律偏低(4)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/max/get

scoreboard players set #up_max zx.meta 0
execute store result score #up_max zx.meta run data get storage manacore:out r.value 1
scoreboard players operation #up_max zx.meta *= #up_pct zx.meta
scoreboard players operation #up_max zx.meta += #5000 zx.meta
scoreboard players operation #up_max zx.meta /= #10000 zx.meta
scoreboard players operation #up_gain zx.meta += #up_max zx.meta

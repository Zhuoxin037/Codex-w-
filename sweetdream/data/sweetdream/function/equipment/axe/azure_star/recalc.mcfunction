# ============================================================
# sweetdream:equipment/axe/azure_star/recalc —— 段①: 消费"被动翻倍" + 算 最大魔力值 ×0.5
# ------------------------------------------------------------
# 【谁调用它】azure_star/cast(⑥)
# 【执行者】施法者(玩家)
# 【★ 被动翻倍的消费点就在这 ★】玩家 2026-10-07 定: "增加至技能倍率上, 而使用后消除"。
#   所以:
#     ① 一进来就把 zx.as_x2 读进 #as_x2, 并**立刻把玩家身上清零**(这就是"使用后消除");
#     ② 段① 在填好 max_mana_mul 之后、api/damage/calc 之前, 若 #as_x2 = 1 就把
#        max_mana_mul ×2(见 double) —— 也就是"增加至技能倍率上"。
#   ★ 为什么还要写 zx.as_db: 两段现在**隔 0.35 秒**分两次结算(2026-10-07 用户口径),
#     标记已经清零了, 段② 得知道"这次该不该 ×2" —— 于是把 #as_x2 记进玩家计分项
#     zx.as_db, 由 dmg2 消费后清零(as_db = "本武器这次技能的伤害倍率翻倍" 的存根)。
# 【★ 为什么 max_mana_mul 而不是 independent_multiplier ★】文案是"该武器伤害倍率",
#   而本武器两段都以最大魔力值结算 -> 就是 max_mana_mul 这条通道;
#   不是"整体再乘一次"的独立乘区。
# 【★ 「最大魔力值技能倍率」通用加成自动生效 ★】2026-10-07 起"风声 / 忘川彼岸 /
#   无效"的加成改走 damage_calc 事件钩子(lib/mm_add/hook_calc), 本武器两段都以最大
#   魔力值结算, 于是**不需要在本文件里显式接一行**就吃得到 —— 旧版那条"批1/批2 的
#   mm 武器一律没接风声"的欠账至此自动结清。
# 【★ zx:work asz 只在"同一刻内"存在 ★】recalc 写 dmg1 -> 同一次调用链里 dmg 立刻读走,
#   不跨刻(跨刻那份值会被别的施法者/技能覆盖, 见回锋/红莲 recalc 头注释)。
# ============================================================

# ⓪ 读一次"被动翻倍"并当场清零(使用后消除), 同时留一份存根给段②
scoreboard players set #as_x2 zx.meta 0
execute if score @s zx.as_x2 matches 1.. run scoreboard players set #as_x2 zx.meta 1
scoreboard players set @s zx.as_x2 0
scoreboard players operation @s zx.as_db = #as_x2 zx.meta

# 段1: 最大魔力值 ×0.5
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.5,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
# 被动翻倍 -> 本武器伤害倍率 ×2
execute if score #as_x2 zx.meta matches 1.. run function sweetdream:equipment/axe/azure_star/double
function manacore:api/damage/calc
data modify storage zx:work asz.dmg1 set from storage manacore:out r.damage

# ============================================================
# sweetdream:internal/damage/out_mul_tag —— 白昼梦: 施法者**自身技能伤害** -20%
# ------------------------------------------------------------
# 【执行者】施法者(@s)   【谁调它】api/damage(且 @s 带 zx.status.dream 才调)
# 【做什么】zx:work a.damage ×0.8
# 【★ 必须在哪里调】api/damage 里 **生成 a.num / a.num_str 之前** —— 本函数只改 a.damage,
#   之后由 api/damage 的 `a.num set from a.damage` 带下去。写在生成之后 = 改了没人读。
# 【★ 对玩家零影响】zx.status.dream 只贴在**非玩家活体**上(tag/mark 排除玩家),
#   所以玩家永远不会命中这条; 只有"会走本包技能系统的怪"才生效。
#   原版生物基本没有技能, 所以这条目前更像面向未来的钩子 —— 当敌方技能实装
#   (走 api/enemy_damage 进来)时它就会**自动生效**: 判据是"施法者 @s 带不带标签",
#   与技能是我方还是敌方无关。
# ============================================================

execute unless data storage zx:work a.damage run return 0
scoreboard players set #ot zx.meta 0
execute store result score #ot zx.meta run data get storage zx:work a.damage 1000
# 【★ R05 整数上界保护(2026-10-10)★】#ot 此刻是**×1000 定点**, 下一步要 ×#80。
#   计分板是 **int32**, 中间值越过 2,147,483,647 会**回绕成负数** —— 不报错,
#   得到的却是一个天文数字或负值(表现就是"伤害突然变成几百亿/负数")。
#   这里补一道动态上限 = INT32_MAX ÷ #80; 常态数值远不到那个量级, 一行都不受影响。
#   ★ 为什么带上 `matches 1..`: 除数如果是 0, 这条 operation **静默失败**(见坑 85 的
#     除零事故), 乘数是百分比加法的结果、被减到 0 以下是有可能的。
#   ★ 为什么不改成"先 ÷100 再 ×": 那会把 45.67 砍成 45, 让常态丢掉小数精度 ——
#     为防一个极端数值牺牲常态精度不划算(vuln_tag 那条注释里有同样的取舍)。
scoreboard players set #ot_cap zx.meta 2147483647
execute if score #80 zx.meta matches 1.. run scoreboard players operation #ot_cap zx.meta /= #80 zx.meta
execute if score #80 zx.meta matches 1.. if score #ot zx.meta > #ot_cap zx.meta run scoreboard players operation #ot zx.meta = #ot_cap zx.meta
scoreboard players operation #ot zx.meta *= #80 zx.meta
scoreboard players operation #ot zx.meta /= #100 zx.meta
execute store result storage zx:work a.damage double 0.001 run scoreboard players get #ot zx.meta

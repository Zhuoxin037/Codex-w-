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
scoreboard players operation #ot zx.meta *= #80 zx.meta
scoreboard players operation #ot zx.meta /= #100 zx.meta
execute store result storage zx:work a.damage double 0.001 run scoreboard players get #ot zx.meta

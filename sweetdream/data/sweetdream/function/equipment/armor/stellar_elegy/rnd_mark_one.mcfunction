# ============================================================
# sweetdream:equipment/armor/stellar_elegy/rnd_mark_one —— 给**这一只**随机附一个效果
# ------------------------------------------------------------
# 【执行者】@s = 那一批里的一只生物(由 rnd_mark 逐个 as 进来)
# 【五个效果等概率】lib/rnd 出 0..32767, %5 得 0..4:
#   0 渊海 / 1 流火 / 2 夜火 / 3 噬心 / 4 白昼梦
# 【★ 每只各掷一次 ★】lib/rnd 每次调用推进一次序列, 而本函数被 as 循环逐个调,
#   所以同一批里五只各附各的 —— 文案写的是"使其随机附加", 每只独立。
# 【★ 走 tag/mark ★】通用标签要带图标与计时, 直接 tag add 只有判定没有表现,
#   而且不会衰减。target 写 "@s" 由宏展开成 `execute as @s`, 就是本函数里这一只。
# 【★ 附完打去重标记 ★】`zx.star_rnd` = "这只已经吃过一次本被动的随机附加" ——
#   调用方 rnd_mark 的选择器靠它排除, 实现"每个生物最多一次"(2026-10-08 用户定稿)。
#   写在**判定之后**: 只有真的附上了才打标记(掷骰异常导致 5 个分支都没命中时不打,
#   免得白白浪费掉这只生物的唯一一次名额)。
# ============================================================

function sweetdream:lib/rnd
scoreboard players operation #se_r zx.meta = #rnd zx.meta
scoreboard players operation #se_r zx.meta %= #5 zx.meta

execute if score #se_r zx.meta matches 0 run data modify storage zx:work ic set value {target:"@s",mark:"yuanhai"}
execute if score #se_r zx.meta matches 0 run function sweetdream:tag/mark with storage zx:work ic
execute if score #se_r zx.meta matches 1 run data modify storage zx:work ic set value {target:"@s",mark:"liuhuo"}
execute if score #se_r zx.meta matches 1 run function sweetdream:tag/mark with storage zx:work ic
execute if score #se_r zx.meta matches 2 run data modify storage zx:work ic set value {target:"@s",mark:"yehuo"}
execute if score #se_r zx.meta matches 2 run function sweetdream:tag/mark with storage zx:work ic
execute if score #se_r zx.meta matches 3 run data modify storage zx:work ic set value {target:"@s",mark:"shixin"}
execute if score #se_r zx.meta matches 3 run function sweetdream:tag/mark with storage zx:work ic
$execute if score #se_r zx.meta matches 4 run data modify storage zx:work ic set value {target:"@s",mark:"dream",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute if score #se_r zx.meta matches 4 run function sweetdream:tag/mark_owned with storage zx:work ic

execute if score #se_r zx.meta matches 0..4 run tag @s add zx.star_rnd

# ============================================================
# fallendream:equipment/bow/ember_string/ol_check —— 烬弦·超限：三种效果是否在 12 秒内集齐
# ------------------------------------------------------------
# 【执行者】被命中那只生物
# 【入参】zx:work es {uuid, u0..u3}
# 【判据】es_t1 / es_t2 / es_t3 三个"最近触发刻"都在 1 以上(触发过)且都 >= #es_cut
#   ⇒ #es_cut = #now - 240, 也就是 12 秒内。
# 【★ 没分数 == 没触发过 ★】`add 0` 把"没分数"补成 0, 之后 `matches 1..` 就能一次
#   表达"触发过"; 反过来"从没触发过"和"触发刻是 0"在这里语义相同(都不会发奖),
#   所以不需要另记"有没有触发过"的旗子。
# ============================================================

scoreboard players add @s zx.es_t1 0
scoreboard players add @s zx.es_t2 0
scoreboard players add @s zx.es_t3 0

execute unless score @s zx.es_t1 matches 1.. run return 0
execute unless score @s zx.es_t2 matches 1.. run return 0
execute unless score @s zx.es_t3 matches 1.. run return 0
execute if score @s zx.es_t1 < #es_cut zx.meta run return 0
execute if score @s zx.es_t2 < #es_cut zx.meta run return 0
execute if score @s zx.es_t3 < #es_cut zx.meta run return 0

function fallendream:equipment/bow/ember_string/ol_reward with storage zx:work es

# ============================================================
# sweetdream:equipment/staff/triad/hit_more —— 「额外发射 2 次」: 补打 2 下
# ------------------------------------------------------------
# 【谁调用它】ball_hit(球上带着 tri_extra:2 时)
# 【执行者】法球(@s); 命中的生物 = @e[tag=zx.ball_hit]
# 【为什么不是"多发射两颗球"】同一刻发三颗球会叠在同一条弹道上, 玩家看不出"额外两次";
#   而且三颗球各自会再触发一次本回调 ⇒ 指数爆炸。所以在命中后**原地补两下伤害**,
#   数值与这一发相同, 归属也照旧。
# 【★ 先把球上的数据搬进 storage ★】下面结算都以"目标"为执行者, 那时读不到球的 data
#   了 —— 必须在切换执行者之前把 dmg / uuid 抄下来。
# 【★ 为什么用递归循环而不是把那行抄两遍 ★】相邻两行命令完全一致会被 check 的
#   "复制粘贴事故"规则拦下(它分不清"故意打两下"和"手滑多粘了一行")。
#   照 dragon_tongue/rain_one 的既有写法用计分项控制次数, 意图也更明白。
# ============================================================

data modify storage zx:work tri.dmg set from entity @s data.dmg
data modify storage zx:work tri.u0 set from entity @s data.u0
data modify storage zx:work tri.u1 set from entity @s data.u1
data modify storage zx:work tri.u2 set from entity @s data.u2
data modify storage zx:work tri.u3 set from entity @s data.u3

scoreboard players set #tri_more zx.meta 0
function sweetdream:equipment/staff/triad/more_one

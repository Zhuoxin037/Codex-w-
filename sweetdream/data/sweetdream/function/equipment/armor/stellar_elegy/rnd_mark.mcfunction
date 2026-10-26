execute store result storage zx:work se_owner.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work se_owner.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work se_owner.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work se_owner.u3 int 1 run scoreboard players get @s manacore.u3
# ============================================================
# sweetdream:equipment/armor/stellar_elegy/rnd_mark —— 超限版追加: 随机附一个效果
# ------------------------------------------------------------
# 【执行者】玩家   【目标】zx.marked(由 lib/marks_any 挑好, 还没被清掉)
# 【文案】…并使其随机附加一个效果。
# 【★ 每只各掷一次 ★】"使其随机附加" —— 每只生物各自独立掷骰, 不是全场共用同一个
#   结果。所以要在 `as @e[tag=zx.marked]` 里逐个调 lib/rnd(它每次调用推进序列)。
# 【五个效果等概率】lib/rnd 出 0..32767, %5 得 0..4:
#   0 渊海 / 1 流火 / 2 夜火 / 3 噬心 / 4 白昼梦
# 【★ 走 tag/mark 而不是直接加 tag ★】通用标签要带图标与计时, 直接 tag add 只有
#   判定没有表现, 而且不会衰减。
# 【★★ 每只生物**最多附一次** ★★】(2026-10-08 用户定稿: "把群星坠落的超限削弱一下,
#   那个随机附加效果每个生物最多一次")
#   本被动是**受击**触发(entity_hurt_player) —— 挨几下就跑几次 AoE。不设限的话,
#   同一只怪连着被附 2 次、3 次…效果层层叠上去(每只都能带好几个通用状态),
#   强度远超"随机附一个"的字面。所以给被附过的生物打一个**持久去重标记**
#   `zx.star_rnd`, 之后它再也不参与本分支(选择器里 tag=!zx.star_rnd 直接排除)。
#   · 标记随实体死亡一并消失 ⇒ 新刷出来的怪照常能被附一次, 不会"整只怪种永久免疫"。
#   · 只是"附加效果"限一次; 那一下的**伤害**(当前魔力 ×0.03)不受影响, 照旧每次结算。
#   · 标记名用 `star_` 前缀(群星) —— `se_` 前缀已被 sculk_echo 占用(见 zx.se_live),
#     沿用会读成"回声的东西"。
# ============================================================

execute as @e[tag=zx.marked,tag=!zx.star_rnd] run function sweetdream:equipment/armor/stellar_elegy/rnd_mark_one with storage zx:work se_owner

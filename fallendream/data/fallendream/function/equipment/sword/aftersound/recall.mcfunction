# ============================================================
# fallendream:equipment/sword/aftersound/recall —— 余响：立即收回一个追随者
# ------------------------------------------------------------
# 【执行者】追随者 marker
# 【和 singer/refund 的区别】
#   · 正常收回：先飞向主人（singer/return 每刻 tp），碰上了才结算 —— 有飞行延迟；
#   · 本件文案："触发一次被动效果后**立即**向自身收回" ⇒ 直接当场结算 + kill。
# 【回蓝 80】文案"收回时恢复的魔力值提升至 80"：把 singer/refund_player 的
#   基数 50 换成 80，合奏层数（每层 +10）照旧保留。
# 【★ 计数 ★】每收回一个，主人的 zx.as_n +1 —— 由 hook_indep 换成 +5% 技能伤害。
# ============================================================

data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=3},limit=1] run return run kill @s

# 合奏层数搬进公共假玩家（refund_heal 读它）
scoreboard players set #j_duet_refund zx.meta 0
scoreboard players operation #j_duet_refund zx.meta = @s zx.j_duet_n

scoreboard players add @a[tag=zx.ub,limit=1] zx.as_n 1

execute at @a[tag=zx.ub,limit=1] as @a[distance=..3] run function fallendream:equipment/sword/aftersound/refund80
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.3 0.4 0.3 0.06 10 normal
kill @s

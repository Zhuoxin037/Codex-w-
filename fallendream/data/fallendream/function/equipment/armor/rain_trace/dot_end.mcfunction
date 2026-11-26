# ============================================================
# fallendream:equipment/armor/rain_trace/dot_end —— 水迹消失：收尸 + 结束挂在它身上的持续伤害
# ------------------------------------------------------------
# 【执行者】水迹点实体（zx.rt_life 归零那一刻，由 dot_tick ① 送进来）
# 【原文】"…持续至其停留的水迹消失。"  ⇒ 这摊没了, 挂在它身上的 DoT 也到此为止。
# 【★ 必须在本摊死以前按编号清 ★】zx.rt_pid 是"归属哪一摊"，只认这一个编号：
#   别的摊的受害者不受影响。不清的话受害者身上留着 zx.rt_lnk，下一摊重新付时
#   会先被本摊抢走一拍（编号不对 → 白扫一遍），也留下永远不会兑现的残留标语。
# 【★ kill 放最后 ★】kill 之后 @s 已经不存在，后面任何 `as @s` 都会失败并写日志。
# ============================================================

scoreboard players operation #rt_mypid zx.meta = @s zx.rt_pid
tag @e[tag=zx.rt_lnk,distance=0..] remove zx.rt_dead
execute as @e[tag=zx.rt_lnk,distance=0..] if score @s zx.rt_pid = #rt_mypid zx.meta run tag @s add zx.rt_dead
tag @e[tag=zx.rt_dead,distance=0..] remove zx.rt_lnk
scoreboard players set @e[tag=zx.rt_dead,distance=0..] zx.rt_pid 0
tag @e[tag=zx.rt_dead,distance=0..] remove zx.rt_dead

# 这摊水迹自己消失
kill @s

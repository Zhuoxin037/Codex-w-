# ============================================================
# sweetdream:equipment/staff/pour_sack/ol_expire —— 倾囊超限：8 秒窗口到点收尸
# ------------------------------------------------------------
# 【谁调用】core/tick（每刻扫 @a[scores={zx.ps_at=1..}]，到点才进来）
# 【★ 为什么三个计分项都要清 ★】
#   ① zx.ps_add：不清的话下一次窗口没开也会继续追伤（数值残留）；
#   ② zx.ps_at ：不清会每刻都判"到点"、每刻都进来一次；
#   ③ #ps_live ：全局闸，不清就永远 ≥1 ⇒ 每一笔固定伤害都要做一次玩家反查（白烧性能）。
# ============================================================
scoreboard players set @s zx.ps_add 0
scoreboard players set @s zx.ps_at 0
execute if score #ps_live zx.meta matches 1.. run scoreboard players remove #ps_live zx.meta 1

# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_enter —— 一只生物"此刻在暗海里"
# ------------------------------------------------------------
# 【谁调用它】sea_tick ④: as @e[tag=zx.sea_hit] unless 带噬心
# 【执行者】那只生物
# 【做三件事】
#   ① 进"本秒受一次暗海伤害"的目标表(zx.sea_hurt_t, 由 sea_hurt 一次性结算)
#   ② 判是不是"还在连续停留", 断了就把踏入时刻(zx.sw_st)重记成现在
#   ③ 从踏入算起已连续停留 ≥ 40 刻(2 秒) → 打 zx.sea_bind, 交给 sea_bind_one 结附
# 【★ 连续性怎么判(2026-10-06 修 bug)★】不再用"每秒清一次"的 zx.in_sea 标签 ——
#   second 的清与 sea_tick 的判在**同一秒**里紧邻, sea_enter 判到的永远是"刚清空",
#   于是每秒都把 sw_st 重置成当前刻, #now - sw_st 恒为 0, 永远到不了 40 刻。
#   改用**时刻差**: zx.sw_last = 上一次被判定在暗海里的时刻。
#     · 距上次判定 ≤ 30 刻 → 认为连续, 不动 sw_st
#     · 否则(新踏入 / 离开过一次) -> sw_st = 现在
#   阈值取 30 的理由: sea_tick 每 20 刻跑一次, 连续时差值正好 20; 同一刻被**两片**
#   暗海各判一次时差值 0 —— 两者都要算连续, 所以区间是 0..30。
#   离开 2 秒(差 40)以上再回来一定重新计时 ✓
# 【初始值】生物第一次进海时 zx.sw_last 还不存在(=0), 差值巨大 -> 不在 0..30 ->
#   自然走"重置"分支 ✓
# 【为什么用计分项记时刻而不是 NBT】实体同样能持分, 且 `operation -= @s zx.sw_st`
#   一行就能求差; NBT 得先 data get 到假玩家再减, 多两步。
# ============================================================

# ① 本秒受一次暗海伤害
tag @s add zx.sea_hurt_t

# ② 连续吗? 断了就把"踏入时刻"重记成现在
scoreboard players set #st zx.meta 0
scoreboard players operation #st zx.meta = #now manacore.meta
scoreboard players operation #st zx.meta -= @s zx.sw_last
execute unless score #st zx.meta matches 0..30 run scoreboard players operation @s zx.sw_st = #now manacore.meta

# ③ 记下"本刻被判定在海里"(供下一秒判连续)
scoreboard players operation @s zx.sw_last = #now manacore.meta

# ④ 从踏入到现在够 2 秒(40 刻)?
scoreboard players operation #st zx.meta = #now manacore.meta
scoreboard players operation #st zx.meta -= @s zx.sw_st
execute if score #st zx.meta matches 40.. run tag @s add zx.sea_bind

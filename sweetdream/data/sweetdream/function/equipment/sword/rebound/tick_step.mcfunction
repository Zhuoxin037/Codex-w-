# ============================================================
# sweetdream:equipment/sword/rebound/tick_step —— 「每 0.35 秒重复一次」的每刻驱动
# ------------------------------------------------------------
# 【谁调用它】core/tick: as @a[scores={zx.rb_t=1..}] at @s run function .../tick_step
# 【执行者】正在等下一次打击的施法者   【位置】他所在处(at @s)
# 【计时口径】zx.rb_t 起手 7, 每刻 -1; 从 1 减到 0 的那一次正好过了 7 刻 = 0.35 秒 -> 打。
#   ★ 筛选用 `zx.rb_t=1..` 是个天然的停摆: 打完若还有剩(rep>=1)就把 rb_t 重置回 7,
#     继续被选中; 打完了(rep<=0)就让它停在 0 -> 再也不被选中, 不用额外清理。
# 【★ 伤害为什么每次重算 ★】见 recalc 头注释: zx:work rba 是共享节点, cast 那刻算好的
#   值不能跨刻留着。这里当场算、当场展开。
# 【谁还会改它】cast(起手排次数) / core/load(计分项注册)
# ============================================================

# ① 倒计时
scoreboard players remove @s zx.rb_t 1
execute if score @s zx.rb_t matches 1.. run return 0

# ② 到点: 重算伤害 -> 打一次"前方 3×5"
function sweetdream:equipment/sword/rebound/recalc
function sweetdream:equipment/sword/rebound/strike with storage zx:work rba

# ③ 还剩几层? 有 -> 重新上弦 7 刻; 没有 -> 停在 0(core/tick 不再选中)
scoreboard players remove @s zx.rb_rep 1
execute if score @s zx.rb_rep matches 1.. run scoreboard players set @s zx.rb_t 7

# 表现: 每段之间一声轻响, 让"还在连击"听得出来
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.5 1.4

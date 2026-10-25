# ============================================================
# sweetdream:equipment/sword/rebound/tick_step —— 「每 0.5 秒重复一次」的每刻驱动
# ------------------------------------------------------------
# 【谁调用它】core/tick: as @a[scores={zx.rb_t=1..}] at @s run function .../tick_step
# 【执行者】正在等下一次打击的施法者   【位置】他所在处(at @s)
# 【计时口径】zx.rb_t 起手 7, 每刻 -1; 从 1 减到 0 的那一次正好过了 10 刻 = 0.5 秒 -> 打。
#   ★ 筛选用 `zx.rb_t=1..` 是个天然的停摆: 打完若还有剩(rep>=1)就把 rb_t 重置回 7,
#     继续被选中; 打完了(rep<=0)就让它停在 0 -> 再也不被选中, 不用额外清理。
# 【★ 伤害为什么每次重算 ★】见 recalc 头注释: zx:work rba 是共享节点, cast 那刻算好的
#   值不能跨刻留着。这里当场算、当场展开。
# 【★ 倍率为什么也每段变 ★】超限·回锋是"每重复一次, 当次倍率翻倍" ⇒ 这一段打之前
#   先把 zx.rb_omul ×2(步骤 ②.1), 再 recalc 换算。未超限恒 ×2(不会进那条 if)。
# 【谁还会改它】cast(起手排次数) / core/load(计分项注册)
# ============================================================

# ① 倒计时
scoreboard players remove @s zx.rb_t 1
execute if score @s zx.rb_t matches 1.. run return 0

# ② 到点: 重算伤害 -> 打一次"前方 3×5"
#   ②.1 ★ 超限·回锋: **每重复一次, 这一段自己的倍率翻倍**(2026-10-23 用户纠正口径:
#      "每重复一次则当次伤害加倍率, 而不是整体加倍率")。
#      起手那一段是 ×2(2000), 这里每次重复 ×2 ⇒ 2→4→8→16→32。
#      ★ 判 zx.rb_ol(起手拍的玩家级旗标)而不是再 `if items` 判一次: 连击跨 0.5 秒,
#        这一段打的时候手上的剑未必还是回锋, 判物品会漏掉后面几段。
execute if score @s zx.rb_ol matches 1 run scoreboard players operation @s zx.rb_omul *= #2 zx.meta
function sweetdream:equipment/sword/rebound/recalc
function sweetdream:equipment/sword/rebound/strike with storage zx:work rba

# ③ 还剩几层? 有 -> 重新上弦 10 刻; 没有 -> 停在 0(core/tick 不再选中)
scoreboard players remove @s zx.rb_rep 1
execute if score @s zx.rb_rep matches 1.. run scoreboard players set @s zx.rb_t 10

# 表现: 每段之间一声轻响, 让"还在连击"听得出来
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.5 1.4

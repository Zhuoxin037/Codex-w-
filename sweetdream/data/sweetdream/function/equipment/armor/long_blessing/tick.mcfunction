# ============================================================
# sweetdream:equipment/armor/long_blessing/tick —— 长祝状态机 + 头盔被动
# ------------------------------------------------------------
# 【谁调用】core/tick：execute as @a at @s run function sweetdream:equipment/armor/long_blessing/tick
# 【执行者】全体玩家 @a（长祝会赋予给 8 格内队友，队友不穿本头盔，故本函数
#   不能整体判穿着；"穿头盔"只在 on_pay 的赋予分支里判）
# 【★ 付费信号 ★】zx.j_pay_t = 最近一次**成功扣费**的绝对刻，由
#   profession/paid（lib/mana/pay 每次成功付费后调用）写入；zx.j_paid = 该笔
#   付费额（魔力 ×1000 毫点），由 profession/pay_prepare 写入。
#   ★ 不能用 zx.it_sum：那是「蓄意」胸甲的消费账本，intent/tick 在没穿蓄意时
#     每刻把它清零，且攒够 50000 会扣减 ⇒ 快照增量法在这里会静默永不触发。
#   ★ 自有快照 zx.lb_prev 记"上次处理过的付费刻"，只在新付费时进一次。
# ============================================================

# ① 本刻是否有新的成功付费
scoreboard players add @s zx.lb_prev 0
scoreboard players add @s zx.j_pay_t 0
scoreboard players set #lb_new zx.meta 0
execute if score @s zx.j_pay_t > @s zx.lb_prev run scoreboard players set #lb_new zx.meta 1
scoreboard players operation @s zx.lb_prev = @s zx.j_pay_t

# ② 新付费 -> 赋予(穿头盔 + 单笔 ≥240 魔力) / 延长(持有长祝 + 任意实际付费)
execute if score #lb_new zx.meta matches 1 run function sweetdream:equipment/armor/long_blessing/on_pay

# ③ 长祝计时(12 秒到期 / 每 2 秒一跳)
execute unless score @s zx.lb_end matches 1.. run return 0
execute if score @s zx.lb_end <= #now manacore.meta run return run function sweetdream:equipment/armor/long_blessing/expire
execute if score @s zx.lb_next <= #now manacore.meta run function sweetdream:equipment/armor/long_blessing/heal_tick

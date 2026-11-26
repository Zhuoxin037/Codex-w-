# ============================================================
# fallendream:equipment/armor/falling_deep/tick —— 落溟：识别"自身释放技能"
# ------------------------------------------------------------
# 【谁调用】core/tick：execute as @a run function fallendream:equipment/armor/falling_deep/tick
# 【执行者】全体玩家 @a（每刻）
# 【技能原文（逐字）】最大魔力值 +100。自身释放技能后在自身位置展开半径 3 格、
#   持续 5 秒的领域，该领域占 1 个术阵位，每 12 秒最多一次……
# 【★ 释放技能的可靠信号 ★】zx.j_pay_t = 最近一次**成功扣费**的绝对刻，由
#   profession/paid（lib/mana/pay 每次成功付费后调用）写入。
#   ★ 不能用 zx.it_sum：那是「蓄意」胸甲的消费账本，intent/tick 在没穿蓄意时
#     每刻清零、攒够 50000 还会扣减 ⇒ 增量法会静默永不触发。
#   ★ 自有快照 zx.fd_prev 记"上次处理过的付费刻"；没穿落溟时也照常推进，
#     否则脱下期间扣的蓝会在重新穿上第一刻被算成一次新付费、白送一次触发。
# ============================================================

# ① 本刻是否出现新的成功付费
scoreboard players add @s zx.fd_prev 0
scoreboard players add @s zx.j_pay_t 0
execute if score @s zx.j_pay_t > @s zx.fd_prev if items entity @s armor.feet *[minecraft:custom_data~{zx:["falling_deep"]}] run function fallendream:equipment/armor/falling_deep/cast

# ② 无论触发与否都推进快照
scoreboard players operation @s zx.fd_prev = @s zx.j_pay_t

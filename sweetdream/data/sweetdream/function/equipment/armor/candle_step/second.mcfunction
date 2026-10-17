# ============================================================
# sweetdream:equipment/armor/candle_step/second —— 残烛: 每秒收掉过期的 +10% 基础攻击力
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second（对 @a 广播）
# 【执行者】每个玩家
# 【文案(套装段)】自身技能成功消费夜火后，自身基础攻击力 +10%，**持续 4 秒**…
# 【★ 为什么由每秒来收 ★】那 4 秒是"已获得的限时增益", 不是条件驱动的常驻加成;
#   包内对这类"限时属性修饰符"的既有做法是**存到期刻 + 每秒收**
#   （每秒精度 ⇒ 实际持续 4.0~5.0 秒，误差不超过 1 秒，与 armor_mana/armor_hp
#     那类每秒注册器的粒度一致; 用每刻去收要多花 20 倍开销去换不到 1 秒的精度）。
# 【★ 拆件即清 ★】用户稿总则:"拆去任一成员后，套装增益和私有积攒立即清除" ⇒
#   没穿齐就把那 10% 退掉，不等到期。
# 【★ 早退 ★】绝大多数玩家账本是 0（= 从没触发过），一条 `if score` 就收工了 ——
#   本函数被广播给 @a, 不能让大家每秒都跑去算 attribute。
# ============================================================

# ① 没有待回收的账本 -> 收工（同时也满足 check.py"广播件必须自带穿着/门控判定"的精神）
execute unless score @s zx.cs_batk matches 1.. run return 0

# ② 到点了吗（4 秒已过）
execute if score @s zx.cs_end < #now manacore.meta run function sweetdream:equipment/armor/candle_step/atk_back

# ③ 拆件即清（任一件不在身上就退掉）—— atk_back 会把账本归零, 所以后面那条自然不成立
execute if score @s zx.cs_batk matches 1.. unless items entity @s armor.chest *[minecraft:custom_data~{zx:["char_coat"]}] run function sweetdream:equipment/armor/candle_step/atk_back
execute if score @s zx.cs_batk matches 1.. unless items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run function sweetdream:equipment/armor/candle_step/atk_back

# ============================================================
# sweetdream:equipment/staff/five_curses/second —— 「世咒」每秒倒计时
# ------------------------------------------------------------
# 【谁调用它】挂进 #manacore:event/second(每秒一次, 全包统一节拍)
# 【做什么】每只带世咒的生物 fcv_t -1; 归零 = 世咒到期:
#   · 第五世 → **自动结算终世**(比例 30%, 就是文案里的那个默认比例);
#   · 一至四世 → 直接清掉(那些层是 debuff, 到期就没了)。
# 【★ 为什么要按三个维度各扫一遍 ★】`@e` 只扫**当前**维度, 而本函数是挂在
#   #manacore:event/second 上跑的, 执行上下文的维度不确定 —— 照抄云迹(core/tick
#   里 zx.ct_live 那三条)的老写法, 三个维度各来一次, 免得站在下界的怪世咒永不倒数。
# 【为什么 #fcv_pct 放在这里设】自然到期的一律是 30%, 与主动技能的 80% 区分开;
#   本刻它不会被改, 放在循环外面设一次就行(假玩家在同一刻是同一份值, 不串)。
# ============================================================

scoreboard players set #fcv_pct zx.meta 30

#   【★ 选择器必须带 distance=0.. ★】裸 @e 在 `execute in <维度>` 里会**跨维度**搜全部
#     维度 ⇒ 三个维度各写一遍 = 同一只被处理 3 次(倒计时变成 3 倍速、终世结算 3 次)。
#     加上 distance=0.. 才锁在当前维度(2026-10-06 真实事故, 见 check 规则)。
execute in minecraft:overworld as @e[distance=0..,scores={zx.fcv_t=1..}] at @s run function sweetdream:equipment/staff/five_curses/tick_one
execute in minecraft:the_nether as @e[distance=0..,scores={zx.fcv_t=1..}] at @s run function sweetdream:equipment/staff/five_curses/tick_one
execute in minecraft:the_end as @e[distance=0..,scores={zx.fcv_t=1..}] at @s run function sweetdream:equipment/staff/five_curses/tick_one

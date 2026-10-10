# ============================================================
# sweetdream:lib/on_lightning —— "有人召唤了一道闪电"的公共收尾钩子
# ------------------------------------------------------------
# 【谁调用它】每一处 `summon minecraft:lightning_bolt` 之后(目前两处):
#   · equipment/axe/charge/bolt      (超•负•荷 的每次雷)
#   · equipment/axe/anion/cast       (负离子 自己的雷)
# 【执行者】**召唤这道雷的玩家**   【位置】**落点**
#   调用方必须保证这两个上下文: 下面要按 @s 找"谁的 buff"、按当前位置算范围。
# 【为什么要有这一层】"自身召唤闪电时…"是**跨武器**的效果(负离子放完 8 秒内
#   切到别的武器召唤的雷也该吃), 所以不能写死在某一支武器的 bolt 里 ——
#   否则每加一把会召唤闪电的武器就要回去改一遍。
# 【★ 没接的两个召唤点(有意) ★】
#   威霆(thunderclap/bolt_one) 与 雷鸣(tool/thunder/pend_go) 的雷**没有接**:
#   那两处的闪电必然要"先施放那把武器"才有, 而负离子的窗口只有 8 秒 ——
#   8 秒内切过去再走完冷却在实战里到不了。要接的话在它们 summon 之后补一行
#   `execute at @s as @a[tag=zx.mc_by] run function sweetdream:lib/on_lightning`
#   即可(pend_go 已经有 zx.mc_by 这个"释放者"标记)。
# ============================================================

# ① 负离子·超限: 8 秒内自身召唤闪电 → 闪电额外对落地处造成 当前魔力 ×0.1
execute if score @s zx.an_boost matches 1.. at @s run function sweetdream:equipment/axe/anion/ol_bonus

# ② 超•负•荷·超限(第二形态): 每次召唤闪电 → 对落点处的生物造成 基础攻击力 ×3
execute if score @s zx.chg_mode matches 1 at @s run function sweetdream:equipment/axe/charge/ol_bolt_bonus

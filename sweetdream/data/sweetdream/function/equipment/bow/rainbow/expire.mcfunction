# ============================================================
# sweetdream:equipment/bow/rainbow/expire —— 漫彩结束
# ------------------------------------------------------------
# 【谁调它】second ①(执行者 = 带漫彩的那只生物, rb_end <= #now)
# 【文案】若「漫彩」在 5 秒内结束, 则对其 2 格内的生物造成 其最大生命值 ×0.2 的伤害。
# 【5 秒内怎么判】(rb_end - rb_born) <= 100 tick 即"实际只持续了 ≤5 秒"
#   (正常是 200; 每吞噬一次 -20, 被吞 ≥5 次就 ≤100)。
# 【范围伤数值】用**该生物自己**的 max_health ×0.2(文案"其最大生命值")。
# 【无论如何都摘标签】哪怕没触发范围伤, 漫彩这一轮也结束了。
# ============================================================

# ① 判 5 秒内
scoreboard players operation #rb_life zx.meta = @s zx.rb_end
scoreboard players operation #rb_life zx.meta -= @s zx.rb_born
tag @e[tag=zx.rb_aoe] remove zx.rb_aoe
execute if score #rb_life zx.meta matches ..100 run function sweetdream:equipment/bow/rainbow/expire_hit

# ② 摘标签 + 清计分(结束)
tag @s remove zx.rb_rainbow
scoreboard players reset @s zx.rb_end
scoreboard players reset @s zx.rb_born

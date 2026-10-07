# ============================================================
# sweetdream:equipment/bow/rainbow/second —— 漫彩每秒推进
# ------------------------------------------------------------
# 【谁调它】lib/second: 对所有带 zx.rb_rainbow 的生物每秒跑一次(执行者 = 那只生物)。
# 【文案】期间若其有 流火/夜火/渊海/白昼梦/噬心 中任意一个效果, 则消耗该效果并
#   使其受到 施加者最大生命值 ×0.1 的伤害, 之后「漫彩」-1 秒;
#   若「漫彩」在 5 秒内结束, 则对其 2 格内生物造成 施加者最大生命值 ×0.2 的伤害。
# 【★ 顺序 ★】
#   ① 先看"到点了没"(rb_end <= #now): 到点则走结束流程(判 5 秒内 + 范围伤)并摘标签。
#   ② 没到点: 吞噬一个效果(若有) + -1 秒。
#   注意"吞噬"每次都只吞**一个**(文案"任意一个效果"), 优先级按包的常见顺序。
# 【★ 5 秒内结束怎么判 ★】born..end 原长 200 tick(10 秒)。结束时
#   (end - born) <= 100(即 ≤5 秒) 就算"5 秒内结束"。
# 【伤害归属】用生物的 zx.rb_u0..u3 反查施加者; 查不到就无归属。
# ============================================================

# ① 到点: 结束漫彩
execute if score @s zx.rb_end <= #now manacore.meta run function sweetdream:equipment/bow/rainbow/expire
execute unless entity @s[tag=zx.rb_rainbow] run return 0

# ② 没到点: 吞噬一个效果(若有)
scoreboard players set #rb_k zx.meta 0
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players set #rb_k zx.meta 1
execute if entity @s[tag=zx.status.yehuo] run scoreboard players set #rb_k zx.meta 2
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players set #rb_k zx.meta 3
execute if entity @s[tag=zx.status.dream] run scoreboard players set #rb_k zx.meta 4
execute if entity @s[tag=zx.status.shixin] run scoreboard players set #rb_k zx.meta 5
execute unless score #rb_k zx.meta matches 1.. run return 0

# 有可吞的效果: 消耗它 + 结算伤害 + 漫彩 -1 秒
function sweetdream:equipment/bow/rainbow/consume

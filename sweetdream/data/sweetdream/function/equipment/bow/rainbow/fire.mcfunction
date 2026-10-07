# ============================================================
# sweetdream:equipment/bow/rainbow/fire —— 命中结算: 施加「漫彩」(宏 {target,shooter,uuid,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = victim)
# 【文案】使被射中的生物附着 10 秒「漫彩」。
# 【漫彩怎么存】以**被打中的那只**为单位:
#   · 标签 zx.rb_rainbow = "有漫彩"
#   · zx.rb_end  计分项 = 结束时刻(框架时钟 #now + 200)
#   · zx.rb_born 计分项 = 施加时刻(用来判断"是否 5 秒内就结束")
#   · zx.rb_u0..u3       = 施加者 UUID(结算伤害时算归属)
#   每秒由 lib/second 推: 吞噬效果(=消耗并 -1 秒)、到点结束(触发范围伤)。
# 【为什么用标签 + 计分项而不是纯计分】"有没有漫彩"要能被选择器直接筛(tag),
#   "还剩多久"才用计分项。和时停(freeze/timestop)同一套思路。
# 【重复命中】再射一次就把结束时刻重置回 10 秒(延长), 施加者换成新的。
# ============================================================

# ① ok 检查(没扣到魔力那一发 snap.ok=0)
execute unless data storage zx:work rb.snap{ok:1b} run return 0

# ② 给被打中的那只上漫彩
$execute as $(target) run tag @s add zx.rb_rainbow
# 初始: 结束 = now + 200(10 秒), 出生 = now
$execute as $(target) run scoreboard players operation @s zx.rb_end = #now manacore.meta
$execute as $(target) run scoreboard players add @s zx.rb_end 200
$execute as $(target) run scoreboard players operation @s zx.rb_born = #now manacore.meta

# ③ 记施加者(伤害归属): 把 snap 的 u0..u3 写进生物的计分项
data modify storage zx:work rbu set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work rbu.u0 set from storage zx:work rb.snap.u0
data modify storage zx:work rbu.u1 set from storage zx:work rb.snap.u1
data modify storage zx:work rbu.u2 set from storage zx:work rb.snap.u2
data modify storage zx:work rbu.u3 set from storage zx:work rb.snap.u3
$execute as $(target) run function sweetdream:equipment/bow/rainbow/mark_owner with storage zx:work rbu

# ④ 表现
$execute at $(target) run particle minecraft:entity_effect{color:[1.0,0.5,1.0,1.0]} ~ ~1 ~ 1.0 0.6 1.0 1.0 30 normal
$execute at $(target) run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.8 1.4

# ⑤ 收尾
tag @e[tag=zx.rb_v] remove zx.rb_v
tag @e[tag=zx.rb_pl] remove zx.rb_pl
tag @e[tag=zx.rb_arr] remove zx.rb_arr

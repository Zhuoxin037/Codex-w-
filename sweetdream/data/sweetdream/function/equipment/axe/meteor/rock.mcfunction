# ============================================================
# sweetdream:equipment/axe/meteor/rock —— 陨星: 降下一颗「陨石」(item_display)
# ------------------------------------------------------------
# 【谁调用它】meteor/fall ④(被动触发时, 对 zx.mt_hit 里的每一只各降一颗)
# 【执行位置】被砸中那只所在处(调用方用 execute at @e[tag=zx.mt_hit])
# 【为什么要有实体】原来 ④ 只有"火柱 + 爆炸"的粒子, 没有"落下来的东西" ——
#   玩家口径: 陨星砸下来却看不见陨石。2026-10-08 批 D 补上资源包模型(陨石).
# 【怎么落下】不用 Motion(display 实体不吃重力), 也不用 schedule(默认 replace、
#   并发会互相顶掉 —— 见 RULES)。走"实体自己带倒计时 zx.mt_rk, core/tick 每刻推":
#     · 出生点 = 目标处 + 7 格高, 倒计时 4 刻
#     · 每刻 -1.75 格(4 刻降到地面), 归零那刻炸开 + kill 自己
#   ★ 4 刻 = 0.2 秒: 伤害是在 fall ② 当场结算的, 落石必须**很快**, 否则视觉上
#     "先掉血、陨石后到"。7 格 / 4 刻 = 每刻 1.75 格, 够快也就够"砸"。
# 【为什么要先 summon 再 tp 上去】倒计时要写在"刚出生的那一颗"身上。出生在目标处,
#   `distance=..2` 就一定命中它自己(别的石头此刻都在 2 格以外: 上一颗至少还悬在
#   y+3.5 以上、落地那颗已经 kill 且早就不带 zx.mt_new 了)。
# ============================================================

summon minecraft:item_display ~ ~ ~ {Tags:["zx.mt_rock","zx.mt_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:meteor_rock"}},brightness:{sky:15,block:15},shadow_radius:0.7f,shadow_strength:0.8f,interpolation_duration:0,transformation:{translation:[0.0f,0.0f,0.0f],scale:[1.4f,1.4f,1.4f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
execute as @e[type=item_display,tag=zx.mt_new,distance=..2] run scoreboard players set @s zx.mt_rk 4
execute as @e[type=item_display,tag=zx.mt_new,distance=..2] run tp @s ~ ~7 ~
tag @e[type=item_display,tag=zx.mt_new,distance=..2] remove zx.mt_new

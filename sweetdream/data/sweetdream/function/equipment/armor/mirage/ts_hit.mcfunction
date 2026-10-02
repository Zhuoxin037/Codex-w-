# ============================================================
# sweetdream:equipment/armor/mirage/ts_hit —— 找 8 格内穿幻昼的人来结算
# ------------------------------------------------------------
# 【执行者】刚结束时停的那只生物(位置也是它自己)
# 【做两件事】
#   ① 在 8 格内(判定箱相交, 不用 distance —— 高个子脚太远会被漏掉)圈出
#      穿着幻昼的玩家, 只留最近的那一个
#   ② 交给 ts_dmg: 以**那个玩家**的基础攻击力 ×2 打真实伤害
# 【为什么要"只留一个"】伤害数值来自玩家面板, 同时有两个人就不知道该读谁的;
#   而且 `execute as @a[...] if items ... run function` 会给**每个**匹配到的
#   玩家各跑一次, 那就打两遍了。所以先打标签、再用 limit=1 取一个。
# 【为什么标 zx.mr_hit】切到玩家那边算完数值后, 还要回来认"打谁"。
# ============================================================

tag @s add zx.mr_hit

tag @a[tag=zx.mr_p] remove zx.mr_p
execute positioned ~-8 ~-8 ~-8 as @a[dx=16.0,dy=16.0,dz=16.0] if items entity @s armor.legs netherite_leggings[custom_data~{zx:["mirage"]}] run tag @s add zx.mr_p
execute as @a[tag=zx.mr_p,sort=nearest,limit=1] run function sweetdream:equipment/armor/mirage/ts_dmg
tag @a[tag=zx.mr_p] remove zx.mr_p

tag @s remove zx.mr_hit

# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_spawn_small —— 生成一片次级「暗海」
# ------------------------------------------------------------
# 【谁调用它】sea_bind(执行位置 = 结附噬心的那只生物处)
# 【和主片的唯一区别】r=2(半径 2 格 ⇒ 直径 4, scale 0.4) + 入场轨道换成 sea_in4
#   (尺寸不同, 轨道数组不能共用, 见 core/load)。
#   寿命与硬上限**和主片同一套口径**: 基础 3 秒(文案值) + 最多存在 10 秒
#   (2026-10-06 用户口径"还是 5 秒(主片), 但上限 10 秒")。
# 【本体】同主片: minecraft:item_display + 三形态随机(sea_a/b/c, 由 sea_pick_model 挑)。
# 【归属从哪来】释放者此刻不在 @s 上(执行者是生物), 归属改用
#   storage zx:work sea —— 那是 sea_tick 在处理"触发它的那片暗海"时填好的
#   (逐片暗海原子执行, 同刻不会被别人覆盖, 见 sea_tick ②)。
# ============================================================

# ① 随机挑形态 -> 召唤(scale 0.4 = 次级片)
data modify storage zx:work sea_mk set value {model:"sweetdream:sea_a",scale:"0.4f"}
function sweetdream:equipment/armor/styx_walk/sea_pick_model
function sweetdream:equipment/armor/styx_walk/sea_make with storage zx:work sea_mk

# ② 归属(从 zx:work sea 带过来) + 半径 2
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea set value {uuid:"",u0:0,u1:0,u2:0,u3:0,r:2}
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.uuid set from storage zx:work sea.uuid
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u0 set from storage zx:work sea.u0
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u1 set from storage zx:work sea.u1
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u2 set from storage zx:work sea.u2
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u3 set from storage zx:work sea.u3

# ③ 寿命: **基础 3 秒** + **硬上限 10 秒**(与主片同口径; 文案里次级片就是 3 秒)
scoreboard players operation @n[limit=1,tag=zx.sea_new] zx.sea_end = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.sea_new] zx.sea_end 60
scoreboard players operation @n[limit=1,tag=zx.sea_new] zx.sea_cap = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.sea_new] zx.sea_cap 200

# ④ 扩散动画(轨道 sea_in4 = 铺到直径 4)
scoreboard players set @n[limit=1,tag=zx.sea_new] zx.sea_anim 14
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.anim set value {field:"scale",track:"sea_in4",key:"zx.sea_anim",dir:"in"}
tag @n[limit=1,tag=zx.sea_new] add zx.anim
tag @n[limit=1,tag=zx.sea_new] remove zx.sea_new

# ⑤ 表现(量比主片省一半)
particle minecraft:squid_ink ~ ~0.2 ~ 1.2 0.2 1.2 0.01 8 normal
particle minecraft:sculk_soul ~ ~0.3 ~ 1.2 0.2 1.2 0.02 6 normal

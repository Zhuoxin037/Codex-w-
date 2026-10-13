# ============================================================
# sweetdream:equipment/armor/withered_garden/wood_tick —— 朽木的每 2 秒
# ------------------------------------------------------------
# 【谁调用它】withered_garden/second(#now 为偶数秒时; 执行者 = 朽木本体)
# 【文案】"朽木"每 2 秒对其 5 格内的有缓慢效果的生物造成相当于释放者
#   最大魔力值 ×0.08 的伤害, 若该目标同时附有「渊海」效果则额外造成一次伤害。
# 【圈两批目标】hit = 5 格内带缓慢效果的; hit2 = hit ∩ 渊海。
#   两个都是共享临时标签 —— second 逐只朽木原子执行, 不会串。
# 【"有缓慢效果"的判定】实体 NBT active_effects 列表里出现 minecraft:slowness(1.20.2+)
#   (列表按子序列匹配, 任意等级/时长的缓慢都算)。
# 【到期先死】寿命到点先摘标签再 kill, 当拍不再打 —— 死亡优先, 保守取整。
# ============================================================

# ① 到期 → **启动退场动画**(不是直接 kill): 先摘判定标签(不再参与 AoE / 反查玩家),
#   再把动画参数换成 sink_y 轨道(缓入: 先慢后快沉回地里)、dir 改 "out" ——
#   lib/anim_step 走完最后一帧会在原地 kill, 不用自己动手。
#   ★ 摘了 zx.gw_wood 之后 second 就不再调本函数, 天然不会重复启动退场。
#   ★ 粒子/声音在**这里**一次撒够(退场只有 0.7 秒, 每 2 秒的 tick 赶不上)。
execute if score @s zx.gw_end <= #now manacore.meta run tag @s remove zx.gw_wood
execute if score @s zx.gw_end <= #now manacore.meta run scoreboard players set @s zx.gw_anim 14
execute if score @s zx.gw_end <= #now manacore.meta run data modify entity @s data.zx.anim set value {field:"translation",track:"sink_y",key:"zx.gw_anim",dir:"out"}
execute if score @s zx.gw_end <= #now manacore.meta run tag @s add zx.anim
execute if score @s zx.gw_end <= #now manacore.meta run particle minecraft:composter ~ ~0.4 ~ 0.9 0.3 0.9 0.03 22 normal
execute if score @s zx.gw_end <= #now manacore.meta run particle minecraft:ash ~ ~1.6 ~ 0.7 2.0 0.7 0.02 22 normal
execute if score @s zx.gw_end <= #now manacore.meta run playsound minecraft:block.wood.break player @a ~ ~ ~ 0.7 0.5
execute if score @s zx.gw_end <= #now manacore.meta run return 0

# ② 圈目标(先清上一轮残留)
tag @e[tag=zx.gd_hit] remove zx.gd_hit
tag @e[tag=zx.gd_hit2] remove zx.gd_hit2
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..5,nbt={active_effects:[{id:"minecraft:slowness"}]}] add zx.gd_hit
execute as @e[tag=zx.gd_hit] if entity @s[tag=zx.status.yuanhai] run tag @s add zx.gd_hit2

# ③ 表现(腐朽氛围: 灰烬贴着树身飘 + 孢子绕冠散; 每 2 秒一轮, 量给得省)
#   ★ 树 ~5.1 格高(见 wood_spawn 的 scale): 灰烬 1.5±2.2 沿树身, 孢子撒在 4.3 的树冠带
particle minecraft:ash ~ ~1.5 ~ 0.7 2.2 0.7 0.008 9 normal
particle minecraft:spore_blossom_air ~ ~4.3 ~ 0.8 0.7 0.8 0.004 6 normal

# ④ 有目标才打(反查释放者 + 玩家身份结算, 见 wood_set / wood_go)
execute if entity @e[tag=zx.gd_hit] run function sweetdream:equipment/armor/withered_garden/wood_set with entity @s data.zx.gd

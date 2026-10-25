# ============================================================
# sweetdream:equipment/bow/burst_dawn/ammo —— 「用魂灵之影当弹药」的那一发(宏 {uu})
# ------------------------------------------------------------
# 【宏参数】zx:work bd {uu} = 射手 uuid 文本
# 【执行者】射手(玩家); 由 shot 直接调
# 【做什么】
#   ⓪ 先把"这一发走了续轰吗"(#bd_hit)清成 0 —— 必须在任何 return 之前
#   ① 数出场上"属于我"的影有几只
#   ② 一只都没有 -> 直接收工(不扣魔力、不动箭), #bd_hit 保持 0
#   ③ 有 -> **当场吃掉最近的一只**当弹药, #bd_hit 记 1, 口径记成续轰(zx.bd_mode=2)
# 【★ 坑 143: 一个计分项只能代表一件事(与坑 136 / 坑 123 同族) ★】
#   曾经这里只有 #bd_n 一个计分项: ① 数出"吃掉前有几只" -> 拿给 shot 当分流判据;
#   然后为了判"吃掉后是不是归零了"又**把 #bd_n 清零重数了一遍** —— 于是吃掉最后
#   一只的那一发, #bd_n 被写成 0, shot 那句 `if #bd_n matches 1.. run return 0`
#   就不成立了 => 紧接着又走一遍"首发": 再扣 799(于是"魔力不足")、再召两个影、
#   再起一个术阵 —— 用户实测就是"消耗最后一个影的时候就会去试图开技能"。
#   更糟的是: 走到"首发"的魔力不足分支会把 zx.bd_paid 写成 0 => 命中回调整条
#   收工, 又表现为"弩的效果完全不生效"。一条链两个症状, 根因只有这一个。
#   ⇒ 现在三个用途各用一个计分项, 谁也不碰谁的:
#     #bd_hit  = "这一发到底走没走续轰"(shot 的分流判据, **只有本文件写**)
#     #bd_n    = 吃掉**前**有几只
#     #bd_left = 吃掉**后**还剩几只(只用来决定要不要收尾)
# 【★ 为什么"吃掉"要发生在射击这一刻而不是命中那一刻 ★】
#   文案说的是"**当作弹药**" —— 弹药在开火时就消耗掉了, 箭飞不飞得中是另一回事。
#   而且"续轰判定"必须在开火时就有确定答案, 否则同一发箭会因为命中早晚而变成
#   两个不同的技能(坑 98 那类"判定依赖命中时机"的静默坑)。
# 【★ 为什么用 kill 而不是打伤害 ★】/kill 直接移除实体: 不掉物品、不掉经验、
#   不走死亡流程(用户要求: 用影当弹药时要清干净掉落与经验)。
#   ★ 影被怪打死那条路靠 summon 时写的 DeathLootTable:"minecraft:empty" 兜底
#     (见 shade_make), 铁傀儡本体也不掉经验。
# ============================================================

# ⓪ 判据归零: 必须发生在任何 return **之前**, 否则"没影那一发"会误继承上一发的 1
#    (这是坑 143 的孪生陷阱 —— 和寒鸦 clear 写 tier:0 是同一个道理)。
scoreboard players set #bd_hit zx.meta 0

# ① 数"吃掉前"有几只我自己的影
scoreboard players set #bd_n zx.meta 0
$execute as @e[tag=zx.bd_shade,nbt={data:{zx:{bd:{uu:"$(uu)"}}}}] run scoreboard players add #bd_n zx.meta 1
execute if score #bd_n zx.meta matches 0 run return 0

# ② 吃掉最近的一只(走到这里 = 这一发确定是续轰)
scoreboard players set #bd_hit zx.meta 1
$execute at @s run kill @e[tag=zx.bd_shade,nbt={data:{zx:{bd:{uu:"$(uu)"}}}},sort=nearest,limit=1]

# ③ 吃掉之后再数一次(用 #bd_left, **不碰 #bd_n**): 场上没影了 -> 技能立刻收尾
#   (撤术阵 + zx.bd_on 归零)。等 check 每秒扫也能收尾, 但那会让术阵多留将近一秒;
#   吃掉最后一只就是"技能结束"的确定时刻, 就地结算最准
#   (2026-10-12 用户实测: 术阵要过一会才清)。
scoreboard players set #bd_left zx.meta 0
$execute as @e[tag=zx.bd_shade,nbt={data:{zx:{bd:{uu:"$(uu)"}}}}] run scoreboard players add #bd_left zx.meta 1
execute if score #bd_left zx.meta matches 0 run function sweetdream:equipment/bow/burst_dawn/end with storage zx:work bd

# ④ 记下"这一发付过账" + 走续轰口径(**写在射手身上**, 坑 141: 箭上的标签靠不住)
scoreboard players set @s zx.bd_paid 1
scoreboard players set @s zx.bd_mode 2

# ⑤ 表现: 弹药化掉的那只影炸开一团魂火
execute at @s run particle minecraft:soul ~ ~1.2 ~ 0.6 0.6 0.6 0.05 24 normal
execute at @s run playsound minecraft:entity.breeze.wind_burst player @a ~ ~ ~ 0.7 1.3

# ============================================================
# sweetdream:equipment/armor/empty_pillow/passive —— 空枕: 连续 4 秒没造成伤害 -> 静息
# ------------------------------------------------------------
# 【谁调用它】lib/second(每秒, as @a)      【执行者】每个玩家
# 【技能原文】"自身连续 4 秒没有造成伤害后，获得「静息」。"
# 【判据】#now - zx.ep_hit >= 80 刻(4 秒)。zx.ep_hit 由 on_deal 每次造成伤害时刷新。
# 【★ 刚穿上时不能立刻给 ★】没打过人的玩家 zx.ep_hit 是 0(= 世界开头那一刻),
#   #now 早就远大于 80 ⇒ 会"一穿上就有静息"。所以第一次进来先把它设成 #now,
#   等于"从此刻开始数 4 秒"。
# 【★ 只有 4 秒这一条路会发标签, 摘标签只由 on_deal 做 ★】否则打人当刻刷新了
#   ep_hit、本秒又判成"没打"(时序差)会来回抖。
# ============================================================

# ① 没戴空枕 -> 收工(顺手把静息摘掉, 别脱了头盔还留着)
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["empty_pillow"]}] run tag @s remove zx.ep_rest
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["empty_pillow"]}] run return 0

# ② 首次计数: 没有记录的人从"现在"开始数
scoreboard players add @s zx.ep_hit 0
execute if score @s zx.ep_hit matches 0 run scoreboard players operation @s zx.ep_hit = #now manacore.meta

# ③ 距上次造成伤害多久了
scoreboard players operation #ep_gap zx.meta = #now manacore.meta
scoreboard players operation #ep_gap zx.meta -= @s zx.ep_hit

# ④ 满 4 秒 -> 静息(只在"刚获得"那一秒出表现)
scoreboard players set #ep_new zx.meta 0
execute if score #ep_gap zx.meta matches 80.. unless entity @s[tag=zx.ep_rest] run scoreboard players set #ep_new zx.meta 1
execute if score #ep_new zx.meta matches 1 run tag @s add zx.ep_rest
execute if score #ep_new zx.meta matches 1 at @s run particle minecraft:dust{color:[0.80,0.72,0.95],scale:1.0} ~ ~1 ~ 0.5 0.5 0.5 0.01 10 normal
execute if score #ep_new zx.meta matches 1 run playsound minecraft:block.wool.step player @a ~ ~ ~ 0.4 0.7

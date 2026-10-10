# ============================================================
# sweetdream:debug/iframe —— 验证"技能伤害会不会被受伤无敌帧吃掉"
# ------------------------------------------------------------
# 【用法】站在一只**血够多**的生物旁边(5 格内最近的那只), 执行:
#     /function sweetdream:debug/iframe
# 【它做什么】同一 tick 对那只生物连打两下**一样大**的伤害(各 1.0), 然后报血量变化:
#     · 掉血 2.00  -> 两下都生效, sweetdream:skill 的 bypasses_cooldown 起作用了(正常)
#     · 掉血 1.00  -> 第二下被无敌帧吃了(说明伤害类型没挂进原版标签)
#   为什么两下要一样大: 原版的规则是"无敌帧里只有伤害更高才生效一部分",
#   打成 2.0 + 1.0 的话两下都会"生效", 结果看起来正常但其实无敌帧还在 —— 那样就测不准。
# 【测出来是"被吃掉"的话】照着查这两处:
#   ① data/sweetdream/damage_type/skill.json 在不在
#      —— 伤害类型属于**注册表**内容, 只在**进世界**那一刻加载: 第一次装它 / 改过它
#         之后光 /reload 不够, 必须退出世界再进来(这是很多人栽的坑)
#   ② data/minecraft/tags/damage_type/bypasses_cooldown.json 里有没有 sweetdream:skill
#         没有的话(或者上面那行报过"missing following references"), 第二下必被吃
#   实在要先跑起来, 就临时退回原版平砍类型 —— ⚠️ 2026-10-10 起 `minecraft:player_attack`
#     也已被加进 bypasses_cooldown（为了让玩家普攻不被无敌帧吃）, 所以这条退路
#     **不再能"关掉" bypass**（两下仍会全生效）。真要测"被吃掉"的样子, 得另注册一个
#     不加进标签的伤害类型再指过去:
#     /data modify storage zx:config damage_type set value "minecraft:player_attack"
#     /reload
# 【注意】别拿快死的生物测(第二下把它打死就读不到血了, 报的是 0)。
# ============================================================

execute unless entity @e[type=!#sweetdream:no_damage,distance=..5,sort=nearest,limit=1] run return run tellraw @s [{"text":"附近 5 格内没有可打的目标","color":"red"}]

# 冻结目标(打标签), 免得它中途走掉/被别的伤害干扰
tag @e[type=!#sweetdream:no_damage,distance=..5,sort=nearest,limit=1] add zx.ifr_v

# 血量(乘 100 存成整数, 计分板没有小数)
scoreboard players set #hp0 zx.meta 0
scoreboard players set #hp1 zx.meta 0
execute store result score #hp0 zx.meta run data get entity @e[tag=zx.ifr_v,limit=1] Health 100

# 同一 tick 连打两下, 每下 1.0(走正式接口, 用的就是技能那套伤害类型)
data modify storage zx:in arg set value {target:"@e[tag=zx.ifr_v]",damage:1.0}
function sweetdream:api/damage
data modify storage zx:in arg set value {target:"@e[tag=zx.ifr_v]",damage:1.0}
function sweetdream:api/damage

execute store result score #hp1 zx.meta run data get entity @e[tag=zx.ifr_v,limit=1] Health 100
scoreboard players operation #hp0 zx.meta -= #hp1 zx.meta

tellraw @s [{"text":"=== 无敌帧自检 ===","color":"gold","bold":true}]
tellraw @s [{"text":"当前技能伤害类型: ","color":"gray"},{"nbt":"damage_type","storage":"zx:config","color":"aqua"}]
tellraw @s [{"text":"两下各 1.0 -> 期望掉血 200(单位 0.01)","color":"gray"}]
tellraw @s [{"text":"实际掉血: ","color":"gray"},{"score":{"name":"#hp0","objective":"zx.meta"},"color":"white"},{"text":"   (200 = 正常 / 100 = 第二下被吃了)","color":"dark_gray"}]

tag @e[tag=zx.ifr_v] remove zx.ifr_v

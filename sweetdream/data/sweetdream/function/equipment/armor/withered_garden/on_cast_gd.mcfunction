# ============================================================
# sweetdream:equipment/armor/withered_garden/on_cast_gd —— 施放技能: 朽木与渊海
# ------------------------------------------------------------
# 【谁调用它】garden_sea/observe(#manacore:event/cooldown_start 链上, 已判穿着)
#   @s = 施法者本人(本包所有主动技能都在扣完蓝之后才记冷却 → 此刻魔力已扣)
# 【文案】自身每使用一次技能都会在自身 8 格内的随机一个附有「渊海」效果的
#   生物处召唤一个持续 8 秒的"朽木", 之后使自身 6 格内随机一个生物附加
#   「渊海」效果。
# 【8 格内没有渊海生物 → 不召唤】"渊海生物"是召唤位置的前提;
#   6 格的渊海附加没有前提, 有生物就标。
# 【随机怎么挑】sort=random 每次求值都会重挑 → 先 limit=1 冻结成标签再用
#   (沉渊 cast 的既有做法)。
# 【渊海标记走公共接口】tag/mark 自带活体守卫(没有 Health 字段的实体
#   天然被跳过), 头顶出图标, 能被深海回响/套装效果认出来。
# ============================================================

# ① 拿 UUID(wood_spawn 要把归属写上朽木)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 8 格内随机一只渊海生物 → 在它那里召唤朽木
tag @e[tag=zx.gd_seed] remove zx.gd_seed
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,tag=zx.status.yuanhai,sort=random,limit=1] add zx.gd_seed
execute at @e[tag=zx.gd_seed,limit=1] run function sweetdream:equipment/armor/withered_garden/wood_spawn

# ③ 6 格内随机一个生物附加渊海(display 实体被 #sweetdream:no_damage 挡在外面,
#   这里再显式补一道, 免得浪费这次附加)
tag @e[tag=zx.gd_mk] remove zx.gd_mk
execute at @s run tag @e[type=!#sweetdream:no_damage,type=!minecraft:marker,type=!minecraft:block_display,type=!minecraft:item_display,type=!minecraft:text_display,distance=..6,sort=random,limit=1] add zx.gd_mk
execute if entity @e[tag=zx.gd_mk] run data modify storage zx:work ic set value {target:"@e[tag=zx.gd_mk]",mark:"yuanhai"}
execute if entity @e[tag=zx.gd_mk] run function sweetdream:tag/mark with storage zx:work ic

# ④ 收尾
tag @e[tag=zx.gd_seed] remove zx.gd_seed
tag @e[tag=zx.gd_mk] remove zx.gd_mk
execute at @s run particle minecraft:spore_blossom_air ~ ~1 ~ 0.6 0.6 0.6 0.015 12 normal
playsound minecraft:block.moss.place player @a ~ ~ ~ 0.7 0.8

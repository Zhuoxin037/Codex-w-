# ============================================================
# sweetdream:equipment/armor/blaze_armor/hurt —— 焱: 被生物打了之后
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/blaze_armor_hurt(entity_hurt_player)
# 【执行者】玩家(被打的那个人)
# 【技能原文(lore 逐字)】
#   "…攻击自身的生物若未处于燃烧状态，则使其获得 5 秒的燃烧状态并使其获得
#    「流火」效果。若其已处于燃烧状态则自身获得再生Ⅱ效果及力量Ⅲ效果，持续 3 秒。"
# 【四要素】
#   触发 = 自身受到伤害(entity_hurt_player)
#   范围 = 那只打你的生物 / 自身(二选一, 看它烧不烧)
#   次数 = 每次受伤触发一次
#   时长 = 5 秒燃烧 / 3 秒再生Ⅱ+力量Ⅲ
# 【★ 攻击者怎么找 ★】进度只说"玩家受伤了", 不给攻击者实体。照抄
#   immolate/hurt 的笨办法: 由近到远找最近的非玩家实体(3 格 -> 6 格)。
#   远程(箭)打不到实体, 那种情况按"没找到"处理(什么都不发生)。
# 【★ 燃烧判定不能用 {Fire:1..} ★】1.21.5 的 NBT 过滤器不接受范围写法,
#   会让**整个函数加载失败**。改成 data get 出来存进分数再判(见 tinder/ignite)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/blaze_armor_hurt

# ① 穿着门控(认装备用 ~ 部分匹配 + 独有标记)
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["blaze_armor"]}] run return 0

# ② 找攻击者: 3 格内最近的非玩家实体; 没有就放宽到 6 格
tag @e[tag=zx.ba_atk] remove zx.ba_atk
execute at @s run tag @e[type=!#sweetdream:hit_scan_exclude,distance=..3,sort=nearest,limit=1] add zx.ba_atk
execute unless entity @e[tag=zx.ba_atk,limit=1] at @s run tag @e[type=!#sweetdream:hit_scan_exclude,distance=..6,sort=nearest,limit=1] add zx.ba_atk
execute unless entity @e[tag=zx.ba_atk,limit=1] run return 0

# ③ 读它的 Fire(没在烧时字段不存在 -> data get 失败 -> 分数保持 0)
scoreboard players set #ba_f zx.meta 0
execute store result score #ba_f zx.meta run data get entity @e[tag=zx.ba_atk,limit=1] Fire

# ④ 未燃烧 -> 点燃 5 秒(100 tick) + 给「流火」
execute if score #ba_f zx.meta matches ..0 as @e[tag=zx.ba_atk,limit=1] at @s run data merge entity @s {Fire:100s}
execute if score #ba_f zx.meta matches ..0 run function sweetdream:tag/mark {target:"@e[tag=zx.ba_atk,limit=1]",mark:"liuhuo"}
execute if score #ba_f zx.meta matches ..0 at @s run particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.02 12 normal

# ⑤ 已燃烧 -> 自身再生Ⅱ + 力量Ⅲ, 持续 3 秒(等级 Ⅱ = 增幅器 1 / Ⅲ = 2)
execute if score #ba_f zx.meta matches 1.. run effect give @s minecraft:regeneration 3 1 true
execute if score #ba_f zx.meta matches 1.. run effect give @s minecraft:strength 3 2 true
execute if score #ba_f zx.meta matches 1.. at @s run particle minecraft:happy_villager ~ ~1 ~ 0.3 0.4 0.3 0.02 10 normal

tag @e[tag=zx.ba_atk] remove zx.ba_atk

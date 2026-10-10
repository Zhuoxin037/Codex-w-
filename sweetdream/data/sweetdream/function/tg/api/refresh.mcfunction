# ============================================================
# sweetdream:tg/api/refresh —— 给**已经发出去的旧物品**刷一遍标签(批 A)
# ------------------------------------------------------------
# 【为谁】标签是 2026-10-10 才加的: 那之前 give 出来的装备物品上**没有** tags,
#   肉鸽地图查不到它。新 give 的物品天然带标签; 老的用本函数补。
#   (同类的"存量补课": 盔甲/剑 的 item_model 走每秒 sync; 标签是纯数据、量小,
#    用一次性刷新更省 —— 也不占每刻预算。)
#
# 【怎么用】把要刷的装备拿在**副手**, 然后:
#     /function sweetdream:tg/api/refresh
#   名字/描述/升级/超限 一律不动, 只重写 custom_data.tags。不消耗任何东西。
#
# 【改的是"中转架上的那件"】玩家自己的槽位 NBT 写不进去(见 station/api/apply_go
#   头注释), 所以照那套: 临时盔甲架 -> 改 tags -> 送回副手 -> kill。
# 【带超限的物品】表里给出**基础**标签; 若物品身上已经有 custom_data.ol,
#   再补一个 "overlimit"(与敲超限时 apply_go 的做法一致)。
# ============================================================

# ⓪ 中转架(先杀旧架防串味; Marker + 无碰撞, 用完即灭)
kill @e[tag=zx.st_tmp]
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.st_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}
item replace entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand from entity @s weapon.offhand

#    【空手兜底】副手是空的就拆架收工, 别把 NBT 写到空气上
execute unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run kill @e[tag=zx.st_tmp]
execute unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run return 0

# ① 认人: 取 zx[0](= 装备英文 id), 拿去查 tge 表
data remove storage zx:work tgr
data modify storage zx:work tgr.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".zx[0]
execute if data storage zx:work tgr.id run function sweetdream:tg/api/refresh_go with storage zx:work tgr

# ② 带超限的物品: 基础标签之上再补 overlimit
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".tags append value "overlimit"

# ③ 送回副手 + 拆架(用 if items 兜底, 半途失败也不会让装备消失)
execute if items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run item replace entity @s weapon.offhand from entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand
kill @e[tag=zx.st_tmp]

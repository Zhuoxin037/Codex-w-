# 威霆领域：淡金祭环、古符文与小型中央祭印，参考启示录书页；仅一个表现实体。
# 16 单位模型均匀缩放 12，直径 12 格；落雷判定半径仍是 6 格。
# 新纹理为静态透明图，整座法阵由 visual/tick 每四刻插值转动一次，9.6 秒一圈。
# 原有术阵 marker 的寿命、落雷和场地清理逻辑不变；此函数仅负责生成外观。
# ------------------------------------------------------------
# 【★★ 2026-10-10 修 F17: 领域必须记住"自己属于哪座术阵 marker" ★★】
#   旧版 display 只带 zx.tc_dom 标签, 没有任何归属信息 ⇒ 收尾的 field_end 只能
#   `kill @e[tag=zx.tc_dom,distance=..2]`, 而**两座术阵中心相距 <= 2 格**时,
#   先结束的那一座会把**还活着**的那一座的领域一起删掉(术阵逻辑 marker 还在,
#   域模型却没了 —— 玩家看到"圈突然消失")。
#   现在把 marker 自身的 UUID 四段写进 display 的 data.zx.m, 收尾(domain_kill)与
#   孤儿兜底(domain_keep)都按它**精确匹配**。
# 【执行者是谁】domain 由 field 以**施法者玩家**身份、在被击者处调用(不是 marker),
#   所以 marker 的 uuid 要现查: field 特意把 marker 的 zx.tc_new 标签留到本函数
#   跑完才摘(见 field 末尾的注释), 这里用 @n[tag=zx.tc_new] 精确抓到"刚建的那一座"。
# ------------------------------------------------------------

summon minecraft:item_display ~ ~0.06 ~ {Tags:["zx.tc_dom","zx.tc_dom_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:domain"}},brightness:{sky:15,block:15},view_range:4.0f,interpolation_duration:0,transformation:{translation:[0.0f,0.0f,0.0f],scale:[12.0f,12.0f,12.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}

# 记下归属: 本座术阵 marker 的 UUID 四段(收尾/兜底按它认亲)
data modify entity @e[tag=zx.tc_dom_new,distance=..2,limit=1] data.zx set value {m:[I;0,0,0,0]}
execute store result entity @e[tag=zx.tc_dom_new,distance=..2,limit=1] data.zx.m[0] int 1 run data get entity @e[tag=zx.tc_new,distance=..2,limit=1] UUID[0]
execute store result entity @e[tag=zx.tc_dom_new,distance=..2,limit=1] data.zx.m[1] int 1 run data get entity @e[tag=zx.tc_new,distance=..2,limit=1] UUID[1]
execute store result entity @e[tag=zx.tc_dom_new,distance=..2,limit=1] data.zx.m[2] int 1 run data get entity @e[tag=zx.tc_new,distance=..2,limit=1] UUID[2]
execute store result entity @e[tag=zx.tc_dom_new,distance=..2,limit=1] data.zx.m[3] int 1 run data get entity @e[tag=zx.tc_new,distance=..2,limit=1] UUID[3]
tag @e[tag=zx.tc_dom_new,distance=..2,limit=1] remove zx.tc_dom_new

# ============================================================
# fallendream:debug/shade_read —— 把「魂灵之影」的定位实测数字打到聊天栏
# ------------------------------------------------------------
# 【谁调用它】debug/shade 末尾 `schedule … 5t`(等跟随跑过几轮再读)
# 【★ 用 @a 而不是 @s ★】schedule 出来的函数**执行者是服务器**, 没有 @s,
#   写 tellraw @s 会静默什么都不显示(旧版就是这个毛病)。
# 【三个数, 单位都是千分之一格】
#   g = 载具(铁傀儡)的 y
#   d = 载体的 y        ← 载体每刻 tp 到载具位置, 所以 d 必须**等于** g
#   t = translation[1]  ← 固定 0.5 格 = 500‰(只补模型自身的半格下沉)
# 【怎么读】
#   · d − g = 0 ⇒ 跟随生效(这是这版的关键: 不再依赖挂载高度)。
#   · t = 500 且 d = g 而模型仍浮空/陷地 ⇒ 问题不在定位, 而在模型自身的
#     "底部相对实体位置的偏移"不是 −0.5 格, 那就把 shade_make 里 translation
#     的 0.5 上下调(差多少补多少)。
# ============================================================

tellraw @a [{"text":"── 魂灵之影 定位诊断 ──","color":"gold"}]
execute unless entity @e[tag=zx.bd_shade,distance=..8,limit=1] run tellraw @a [{"text":"  没读到影：它已经不在了（寿命到/被打死），再跑一次 debug/shade。","color":"red"}]
scoreboard players set #bdok zx.meta 0
execute if entity @e[tag=zx.bd_shade,distance=..8,limit=1] run scoreboard players set #bdok zx.meta 1
execute if score #bdok zx.meta matches 1 store result score #bdgy zx.meta run data get entity @e[tag=zx.bd_shade,distance=..8,sort=nearest,limit=1] Pos[1] 1000
execute if score #bdok zx.meta matches 1 store result score #bddy zx.meta run data get entity @e[type=minecraft:item_display,tag=zx.bd_model,distance=..8,sort=nearest,limit=1] Pos[1] 1000
execute if score #bdok zx.meta matches 1 store result score #bdtr zx.meta run data get entity @e[type=minecraft:item_display,tag=zx.bd_model,distance=..8,sort=nearest,limit=1] transformation.translation[1] 1000
execute if score #bdok zx.meta matches 1 store result storage zx:work bdm.dbg.g int 1 run scoreboard players get #bdgy zx.meta
execute if score #bdok zx.meta matches 1 store result storage zx:work bdm.dbg.d int 1 run scoreboard players get #bddy zx.meta
execute if score #bdok zx.meta matches 1 store result storage zx:work bdm.dbg.t int 1 run scoreboard players get #bdtr zx.meta
execute if data storage zx:work bdm.dbg run tellraw @a ["",{"text":"  载具 y (g) = ","color":"gray"},{"nbt":"dbg.g","storage":"zx:work","color":"white"},{"text":"  ‰","color":"dark_gray"}]
execute if data storage zx:work bdm.dbg run tellraw @a ["",{"text":"  载体 y (d) = ","color":"gray"},{"nbt":"dbg.d","storage":"zx:work","color":"white"},{"text":"  ‰","color":"dark_gray"}]
execute if data storage zx:work bdm.dbg run tellraw @a ["",{"text":"  translation[1] (t) = ","color":"gray"},{"nbt":"dbg.t","storage":"zx:work","color":"white"},{"text":"  ‰","color":"dark_gray"}]
execute if data storage zx:work bdm.dbg run tellraw @a [{"text":"  读法：d 应等于 g（每刻跟随）；t 应恒为 500（= 0.5 格，补模型自身下沉）。","color":"dark_gray"}]

# ============================================================
# sweetdream:equipment/sword/myriad/domain_fx —— 领域的**每刻**视觉
# ------------------------------------------------------------
# 【执行者】领域 marker(由 core/tick 三维度各挑一行)
# 【为什么必须每刻】以前画圈挂在 domain_tick 里、每秒只跑一次 —— 每秒 4 个
#   小尘点在 20 fps 里 19 帧是空的, 玩家反馈"领域不明显", 进而不知道自己
#   有没有站在圈里(而攻击计数 / 特殊技能窗口全判这条边界)。
#   ★ 每刻只画 6 个点不怕疏 ★ dust 粒子打在原地活约 1 秒(≈20 刻), 每刻整体
#     再转 10 度 => 同一圈上会同时摞着 6×20 = 120 个点, 看上去就是**一整圈**,
#     而且它在慢慢转。用 6 条命令/刻换来整圈, 比"每秒 24 条"省得多。
# 【转速】zx.mq_fa 每刻 +10 => 36 刻(1.8 秒)转满一圈。
# ============================================================

scoreboard players add @s zx.mq_fa 10
execute if score @s zx.mq_fa matches 360.. run scoreboard players remove @s zx.mq_fa 360

# ① 边界圈: 6 个方位, 每个间隔 60 度
scoreboard players operation #mq_da zx.meta = @s zx.mq_fa
execute store result storage zx:work mqd.a int 1 run scoreboard players get #mq_da zx.meta
function sweetdream:equipment/sword/myriad/domain_ring with storage zx:work mqd

scoreboard players add #mq_da zx.meta 60
execute if score #mq_da zx.meta matches 360.. run scoreboard players remove #mq_da zx.meta 360
execute store result storage zx:work mqd.a int 1 run scoreboard players get #mq_da zx.meta
function sweetdream:equipment/sword/myriad/domain_ring with storage zx:work mqd

scoreboard players add #mq_da zx.meta 60
execute if score #mq_da zx.meta matches 360.. run scoreboard players remove #mq_da zx.meta 360
execute store result storage zx:work mqd.a int 1 run scoreboard players get #mq_da zx.meta
function sweetdream:equipment/sword/myriad/domain_ring with storage zx:work mqd

scoreboard players add #mq_da zx.meta 60
execute if score #mq_da zx.meta matches 360.. run scoreboard players remove #mq_da zx.meta 360
execute store result storage zx:work mqd.a int 1 run scoreboard players get #mq_da zx.meta
function sweetdream:equipment/sword/myriad/domain_ring with storage zx:work mqd

scoreboard players add #mq_da zx.meta 60
execute if score #mq_da zx.meta matches 360.. run scoreboard players remove #mq_da zx.meta 360
execute store result storage zx:work mqd.a int 1 run scoreboard players get #mq_da zx.meta
function sweetdream:equipment/sword/myriad/domain_ring with storage zx:work mqd

scoreboard players add #mq_da zx.meta 60
execute if score #mq_da zx.meta matches 360.. run scoreboard players remove #mq_da zx.meta 360
execute store result storage zx:work mqd.a int 1 run scoreboard players get #mq_da zx.meta
function sweetdream:equipment/sword/myriad/domain_ring with storage zx:work mqd

# ② 中心那根光柱: 领域"在这 Rotch 子中心" —— 只看地面圈的话远处认不出位置
execute at @s run particle minecraft:dust{color:[0.90,0.72,1.0],scale:1.2} ~ ~0.2 ~ 0.25 0.5 0.25 0.02 5 normal
execute at @s run particle minecraft:dust{color:[1.0,0.90,1.0],scale:1.0} ~ ~2.2 ~ 0.5 0.3 0.5 0.02 4 normal

# ============================================================
# sweetdream:equipment/axe/xiugou/ol_bite —— 超限·锈犬的那一口(8 格 + 连击计数)
# ------------------------------------------------------------
# 【执行者】marker(锈犬)
# 【和原版 bite 的差别】
#   ① 撕咬范围 3 -> **8 格**
#   ② 每口伤害已经在 cast 里乘过 2(文案"×2"), 这里只负责投递
#   ③ 多了「连击」: 同一只锈犬对**同一个生物**累计咬满 5 次, 这一口之后
#      额外补一次「基础攻击力 ×5」并给它挂 10 秒「被召唤物攻击 +30%」
# 【★ 连击为什么记在锈犬身上 ★】文案是"锈犬每对一个生物造成了 5 次伤害" ——
#   计数跟着**这一只犬**走。若记在被咬生物身上, 三只犬咬同一只怪就会三倍加速
#   (1.7 秒就触发一次), 与文案不符。
# 【★ 怎么认"还是同一只" ★】marker 上两个计分项 zx.xg_tg / zx.xg_th 存目标
#   的 UUID[3] / UUID[0](两个 32 位整数当指纹)。计分项存不下 128 位 UUID,
#   取两个整数位撞号概率 ≈ 2^-64 —— 撞了也只是"连击没清零", 不会错打别人。
#   (不写 marker 的 NBT: 每秒写一次实体 NBT 会让区块标脏, 见 kardo 卡顿四类)
# 【★ "没有分数 ≠ 0" ★】新召唤的犬没有 xg_hc, 所以比较前先 `add 0` 补齐。
# ============================================================

execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=1] run return 0

# ---- 目标指纹(两次采样, 都是"最近的那一个") ----
scoreboard players set #xg_tg zx.meta 0
scoreboard players set #xg_th zx.meta 0
execute store result score #xg_tg zx.meta run data get entity @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=1] UUID[3]
execute store result score #xg_th zx.meta run data get entity @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=1] UUID[0]

# ---- 换目标 -> 连击清零(任一指纹不同就算换了) ----
scoreboard players add @s zx.xg_hc 0
execute unless score @s zx.xg_tg = #xg_tg zx.meta run scoreboard players set @s zx.xg_hc 0
execute if score @s zx.xg_tg = #xg_tg zx.meta unless score @s zx.xg_th = #xg_th zx.meta run scoreboard players set @s zx.xg_hc 0
scoreboard players operation @s zx.xg_tg = #xg_tg zx.meta
scoreboard players operation @s zx.xg_th = #xg_th zx.meta
scoreboard players add @s zx.xg_hc 1

# ---- 满 5 次: 这一口之后再补一发「基础攻击力 ×5」, 计数归零重新攒 ----
scoreboard players set #xg_burst zx.meta 0
execute if score @s zx.xg_hc matches 5.. run scoreboard players set #xg_burst zx.meta 1
execute if score @s zx.xg_hc matches 5.. run scoreboard players set @s zx.xg_hc 0

# ---- 宏参数: dmg(每口) / bd(×5 那一下) / burst(本口要不要补) / u0..u3 ----
data modify storage zx:work xg set value {dmg:0,bd:0,burst:0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work xg.dmg set from entity @s data.zx.dmg
scoreboard players set #xg_bd zx.meta 0
execute store result score #xg_bd zx.meta run data get entity @s data.zx.dmg
scoreboard players operation #xg_bd zx.meta *= #5 zx.meta
scoreboard players operation #xg_bd zx.meta /= #2 zx.meta
execute store result storage zx:work xg.bd int 1 run scoreboard players get #xg_bd zx.meta
execute store result storage zx:work xg.burst int 1 run scoreboard players get #xg_burst zx.meta
data modify storage zx:work xg.u0 set from entity @s data.zx.u[0]
data modify storage zx:work xg.u1 set from entity @s data.zx.u[1]
data modify storage zx:work xg.u2 set from entity @s data.zx.u[2]
data modify storage zx:work xg.u3 set from entity @s data.zx.u[3]

execute as @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=1] at @s run function sweetdream:equipment/axe/xiugou/ol_bite_one with storage zx:work xg

scoreboard players add @s zx.xg_n 1
execute at @s run particle minecraft:crit ~ ~0.25 ~ 0.3 0.2 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.wolf.bite player @a ~ ~ ~ 0.8 1.0

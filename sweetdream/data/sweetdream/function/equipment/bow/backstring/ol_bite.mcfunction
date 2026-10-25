# ============================================================
# sweetdream:equipment/bow/backstring/ol_bite —— 【超限】被动 8 点固定真伤 + 逐次翻倍
# ------------------------------------------------------------
# 【谁调用它】backstring/fire ③.5(执行者 = 射手, 目标带 zx.bs_v)
# 【文案(超限整段)】
#   「之后对射中的生物附加一次 8 点固定真实伤害。之后对该生物射中一次则该固定伤害
#     翻倍，依靠该被动最多翻倍 3 次。每次翻倍持续 6 秒。」
#   「（弦满）若射中的是被动已经翻倍了 3 次或以上的生物则被动额外再翻倍一次，
#     本次翻倍单独持续 12 秒。」
# 【★ 层数记在**目标身上** ★】文案是"对该生物射中一次则该固定伤害翻倍" ——
#   每只生物各算一套, 换个目标从头 8 点。所以用 zx.bsb_* 打在生物身上
#   (玩家身上只有 zx.bs_ol: "这一发是超限弩射的")。
# 【★ 伤害按**命中前**的层数算 ★】文案说的是"射中一次 -> 则翻倍": 翻倍发生在
#   命中之后, 所以这一发吃的还是旧值(8 -> 16 -> 32 -> 64)。
# 【★ 层数表 ★】总层 = bsb_n(0..3) + bsb_x(0/1)  ⇒  8 / 16 / 32 / 64 / 128
#   ★ 不用循环递乘: 整数分档写 5 条 `set value` 最直观, 也避开
#     `store result double` 的精度坑(那是乘数不是精度)。
# 【★ 真伤走哪 ★】文案明写"固定真实伤害" ⇒ type = sweetdream:true_damage
#   (该类型同时进了 bypasses_armor / bypasses_cooldown)。"固定" = 不进任何乘区,
#   所以直接用 store 出来的整数, **不过** manacore:api/damage/calc。
# 【★ 顺序(不能换) ★】
#   ① 读层数 -> ② 打真伤 -> ③ 弦满额外翻倍判定 -> ④ 普通翻倍 -> ⑤ 计时 +1 + 挂牌
#   ③ 必须在 ④ 之前: ③ 判的是"命中前已经翻满 3 次", 而 ④ 会把 2 层推到 3 层;
#   顺序反了, 第 3 层那发就会白拿一次额外翻倍。
# ============================================================

# ⓪ 目标还在吗(被 ③ 那 30 点 / 上一发打死了就收工)
execute unless entity @e[tag=zx.bs_v,distance=0..,limit=1] run return 0

# ① 先把四个计分项在目标身上建出来 —— "没分数"和"0"在 if score 面前不是一回事
scoreboard players add @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_n 0
scoreboard players add @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_t 0
scoreboard players add @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_x 0
scoreboard players add @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_xt 0

# ② 总层数 = 主层 + 额外层
scoreboard players set #bsb_l zx.meta 0
scoreboard players operation #bsb_l zx.meta = @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_n
scoreboard players operation #bsb_l zx.meta += @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_x

# ③ 这一发的固定真伤 = 8 x 2^层
scoreboard players set #bsb_d zx.meta 8
execute if score #bsb_l zx.meta matches 1 run scoreboard players set #bsb_d zx.meta 16
execute if score #bsb_l zx.meta matches 2 run scoreboard players set #bsb_d zx.meta 32
execute if score #bsb_l zx.meta matches 3 run scoreboard players set #bsb_d zx.meta 64
execute if score #bsb_l zx.meta matches 4.. run scoreboard players set #bsb_d zx.meta 128

# ④ 打出真伤(带射手归属: u0..u3 取自执行者 = 射手)
execute at @s run particle minecraft:crit ~ ~1 ~ 0.3 0.4 0.3 0.04 6 normal
execute as @e[tag=zx.bs_v,distance=0..,limit=1] at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.3 0.4 0.3 0.08 8 normal
execute store result storage zx:work bsb.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work bsb.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work bsb.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work bsb.u3 int 1 run data get entity @s UUID[3]
data modify storage zx:work a set value {target:"@e[tag=zx.bs_v,distance=0..,limit=1]",damage:0.0,type:"sweetdream:true_damage",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work a.u0 set from storage zx:work bsb.u0
data modify storage zx:work a.u1 set from storage zx:work bsb.u1
data modify storage zx:work a.u2 set from storage zx:work bsb.u2
data modify storage zx:work a.u3 set from storage zx:work bsb.u3
execute store result storage zx:work a.damage double 1 run scoreboard players get #bsb_d zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# 诊断锚: #bsb_dbg8 = 这一发的真伤, #bsb_dbg9 = 命中前总层数
scoreboard players set #bsb_dbg8 zx.meta 0
execute store result score #bsb_dbg8 zx.meta run data get storage zx:work a.damage
scoreboard players operation #bsb_dbg9 zx.meta = #bsb_l zx.meta

# ⑤ 弦满: 命中前**已经翻满 3 层**的目标 -> 额外再翻一层(独立 12 秒)
#   ★ 判 zx.bs_ready(弦满那一发) 且 bsb_n >= 3(命中前的主层值, 此刻还没被 ⑥ 改)
execute if score @s zx.bs_ready matches 1 if score @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_n matches 3.. run scoreboard players set @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_x 1
execute if score @s zx.bs_ready matches 1 if score @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_n matches 3.. run scoreboard players set @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_xt 240
execute if score @s zx.bs_ready matches 1 if score @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_n matches 3.. as @e[tag=zx.bs_v,distance=0..,limit=1] at @s run particle minecraft:soul_fire_flame ~ ~1 ~ 0.35 0.5 0.35 0.02 12 normal

# ⑥ 普通翻倍: 主层不到 3 -> +1 层并刷新 6 秒
#   ★ 为什么用 #bsb_up 中转 ★ 「满了不该刷新计时」与「刚好涨到 3 该刷新」在
#     `add 1` 之后**长得一样**(都是 3), 必须先判"这次真的涨没涨"再动手(坑 136 同族)。
scoreboard players set #bsb_up zx.meta 0
execute if score @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_n matches ..2 run scoreboard players set #bsb_up zx.meta 1
execute if score #bsb_up zx.meta matches 1 run scoreboard players add @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_n 1
execute if score #bsb_up zx.meta matches 1 run scoreboard players set @e[tag=zx.bs_v,distance=0..,limit=1] zx.bsb_t 120

# ⑦ 挂上"身上还有退弦层数"的标签 —— ol_tick 只遍历它们(不 tick 全世界的怪)
tag @e[tag=zx.bs_v,distance=0..,limit=1] add zx.bsb

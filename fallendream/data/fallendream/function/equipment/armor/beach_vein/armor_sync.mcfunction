# ============================================================
# fallendream:equipment/armor/beach_vein/armor_sync —— 滩纹: 护甲值差值登记（基础 +2 / 超限 +4 且额外 +10%）
# ------------------------------------------------------------
# 【执行者】每个玩家（由 beach_vein/passive 调用）
# 【文案】自身 5 格内有附有「渊海」的生物时，自身护甲值 +2；
#   超限: 护甲值 +4，且额外 +10%。
#   超限附加: 消耗「渊海」后 6 秒内即使范围内无渊海生物，护甲加成继续保留。
# 【★ 差值制账本 ★】读该不该有(#want) → 与账本比差值 → 先按旧账摘旧 modifier,
#   再按新账加新的（id 固定，重复 add 同一 id 不可靠）。
# 【★ 旧账为 0 时不能 remove ★】没挂过的 modifier 去 remove 会失败并截断整个函数。
# 【★ 两个 modifier 各自独立账本 ★】bv_arm = 固定护甲值(+2/+4);
#   bv_arm_p = +10% 总护甲乘区(超限专属 add_multiplied_total)。各自挂/摘互不干扰。
# 【★ 不用 return 提前退出 ★】两段(固定值 / 百分比)都要跑完；差值相等的分支用
#   execute if 门控，不用 return，否则另一段会被一起吞掉。
# ============================================================

# ---- ① 本秒该不该有（没穿 / 5 格内没有渊海生物 / 保留窗口没开 -> 0） ----
scoreboard players set #bv_want zx.meta 0
tag @e[tag=zx.bv_n,distance=0..] remove zx.bv_n
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"]}] at @s run tag @e[type=!#fallendream:no_damage,distance=..5,tag=zx.status.yuanhai,limit=1] add zx.bv_n

# 基础档：有渊海 -> +2
execute if entity @e[tag=zx.bv_n,distance=0..,limit=1] run scoreboard players set #bv_want zx.meta 2
# 超限档：有渊海 **或** 保留窗口开着 -> +4
scoreboard players set #bv_keep_on zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"],ol:"beach_vein"}] if score @s zx.bv_keep > #now manacore.meta run scoreboard players set #bv_keep_on zx.meta 1
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"],ol:"beach_vein"}] if entity @e[tag=zx.bv_n,distance=0..,limit=1] run scoreboard players set #bv_want zx.meta 4
execute if score #bv_keep_on zx.meta matches 1 run scoreboard players set #bv_want zx.meta 4
tag @e[tag=zx.bv_n,distance=0..] remove zx.bv_n

# ---- ② 固定护甲值：与账本比差值（差值 0 则本段什么都不做，但不 return） ----
scoreboard players add @s zx.bv_arm 0
scoreboard players operation #bv_diff zx.meta = #bv_want zx.meta
scoreboard players operation #bv_diff zx.meta -= @s zx.bv_arm

# 先摘旧 modifier（旧账非 0 且差值非 0 才摘）
execute if score #bv_diff zx.meta matches 1.. if score @s zx.bv_arm matches 1.. run attribute @s minecraft:armor modifier remove fallendream:bv_arm
execute if score #bv_diff zx.meta matches ..-1 if score @s zx.bv_arm matches 1.. run attribute @s minecraft:armor modifier remove fallendream:bv_arm
# 记新账；新账非 0 才加（数值走宏，attribute 只吃命令行字面量）
execute if score #bv_diff zx.meta matches 1.. run scoreboard players operation @s zx.bv_arm += #bv_diff zx.meta
execute if score #bv_diff zx.meta matches ..-1 run scoreboard players operation @s zx.bv_arm += #bv_diff zx.meta
execute store result storage zx:work bv.amt int 1 run scoreboard players get @s zx.bv_arm
execute if score #bv_diff zx.meta matches 1.. if score @s zx.bv_arm matches 1.. run function fallendream:equipment/armor/beach_vein/apply with storage zx:work bv
execute if score #bv_diff zx.meta matches ..-1 if score @s zx.bv_arm matches 1.. run function fallendream:equipment/armor/beach_vein/apply with storage zx:work bv
# ★ 差值 0 时上面"摘旧/加新"都不跑，安全（不重复 add 同一 id）。

# ---- ③ 超限专属 +10% 总护甲乘区：只在 #bv_want==4 时挂，否则撤 ----
#   ★ 账本 bv_arm_p 记"挂没挂"(0/1)，比例型不参与整点差值。
scoreboard players add @s zx.bv_arm_p 0
execute if score @s zx.bv_arm_p matches 1 unless score #bv_want zx.meta matches 4 run attribute @s minecraft:armor modifier remove fallendream:bv_arm_p
execute if score @s zx.bv_arm_p matches 1 unless score #bv_want zx.meta matches 4 run scoreboard players set @s zx.bv_arm_p 0
execute if score @s zx.bv_arm_p matches 0 if score #bv_want zx.meta matches 4 run attribute @s minecraft:armor modifier add fallendream:bv_arm_p 0.1 add_multiplied_total
execute if score @s zx.bv_arm_p matches 0 if score #bv_want zx.meta matches 4 run scoreboard players set @s zx.bv_arm_p 1

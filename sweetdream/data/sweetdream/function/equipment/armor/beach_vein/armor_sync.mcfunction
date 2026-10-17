# ============================================================
# sweetdream:equipment/armor/beach_vein/armor_sync —— 滩纹: 护甲值 +2 的差值登记
# ------------------------------------------------------------
# 【执行者】每个玩家（由 beach_vein/passive 调用）
# 【口径】自身 5 格内有附有「渊海」的生物 -> 护甲值 +2；否则应退成 0。
# 【★ 为什么用账本+attribute modifier ★】包内没有"按条件给护甲"的现成接口；
#   照 fcv4(五世恶咒破甲) / armor/hp 的写法：读该不该有(#want) -> 与账本比差值 ->
#   先按旧账摘旧 modifier, 再按新账加新的（id 固定, 重复 add 同一 id 不可靠）。
# 【★ 旧账为 0 时不能 remove ★】没挂过的 modifier 去 remove 会失败, 失败会
#   **截断整个函数** —— 所以两处都带门控。
# ============================================================

# ---- ① 本秒该不该有（没穿 / 5 格内没有带渊海的生物 -> 0） ----
scoreboard players set #bv_want zx.meta 0
tag @e[tag=zx.bv_n,distance=0..] remove zx.bv_n
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"]}] at @s run tag @e[type=!#sweetdream:no_damage,distance=..5,tag=zx.status.yuanhai,limit=1] add zx.bv_n
execute if entity @e[tag=zx.bv_n,distance=0..,limit=1] run scoreboard players set #bv_want zx.meta 2
tag @e[tag=zx.bv_n,distance=0..] remove zx.bv_n

# ---- ② 与账本比差值 ----
#   ★ 先 `add 0` 把没分数的玩家补成 0（"没分数"时 if score 判不成立, 不能当 0 用）。
scoreboard players add @s zx.bv_arm 0
scoreboard players operation #bv_diff zx.meta = #bv_want zx.meta
scoreboard players operation #bv_diff zx.meta -= @s zx.bv_arm
execute if score #bv_diff zx.meta matches 0 run return 0

# ---- ③ 先摘旧 modifier（旧账非 0 才摘） ----
execute if score @s zx.bv_arm matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:bv_arm

# ---- ④ 记新账；新账非 0 才加（数值走宏，attribute 只吃命令行字面量） ----
scoreboard players operation @s zx.bv_arm += #bv_diff zx.meta
execute store result storage zx:work bv.amt int 1 run scoreboard players get @s zx.bv_arm
execute if score @s zx.bv_arm matches 1.. run function sweetdream:equipment/armor/beach_vein/apply with storage zx:work bv

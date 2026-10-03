# ============================================================
# sweetdream:upgrade/api/bonus_take —— 分级链条: 同系只认最高 tier(宏 {id, series})
# ------------------------------------------------------------
# 【为什么不是累加】文案里"魔力提升·β = 上限 +30"是**这一级的完整效果**,
#   不是"在 α 的 20 上再加 30"。所以 α+β 一起装时按 β 算(30), 不是 50。
#   同理 增殖·Ω 的"回 1.5%"也要盖掉 α 的 5 / β 的 9, 否则会变成 5+9+1.5%。
#
# 【怎么做到"覆盖"】每个 series 一个桶 zx:work up_val."<series>" = 当前生效的那条定义。
#   遇到更高 tier 就: ①把桶里**旧贡献**从总账减掉 ②整条定义换进桶 ③把新贡献加回来。
#   这样不管是 α->β->Ω 还是乱序敲, 总账最后都只剩最高那一级。
#
# 【临时量】#up_mm / #up_mr / #up_mh / #up_mhp 由调用方(bonus_held / bonus_armor)归零。
#   #up_mhp 的单位是 0.01%(1.5% -> 150)
# ============================================================

# 桶不存在就先建一个"空桶", 不然下面第一次 data get 会读不到(分数留旧值)
$execute unless data storage zx:work up_val."$(series)" run data modify storage zx:work up_val."$(series)" set value {tier:0,mm:0,mr:0,mh:0,mhp:0}

scoreboard players set #up_bt zx.meta 0
$execute store result score #up_bt zx.meta run data get storage zx:work up_val."$(series)".tier
# 没有更高就什么也不做(低阶被高阶盖掉了)
execute unless score #up_tier zx.meta > #up_bt zx.meta run return 0

# ① 减掉旧贡献
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mm
scoreboard players operation #up_mm zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mr
scoreboard players operation #up_mr zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mh
scoreboard players operation #up_mh zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mhp 100
scoreboard players operation #up_mhp zx.meta -= #up_o zx.meta

# ② 整条定义换进桶
$data modify storage zx:work up_val."$(series)" set from storage zx:config updef."$(id)"

# ③ 加回新贡献
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mm
scoreboard players operation #up_mm zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mr
scoreboard players operation #up_mr zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mh
scoreboard players operation #up_mh zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mhp 100
scoreboard players operation #up_mhp zx.meta += #up_o zx.meta

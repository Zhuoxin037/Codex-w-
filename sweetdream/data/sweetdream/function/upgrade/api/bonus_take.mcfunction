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
# 【临时量】#up_dmg/#up_mana/#up_cd(乘区, 单位 0.01)、
#   #up_mm/#up_mr/#up_mh/#up_mhp/#up_ar/#up_at/#up_hp/#up_cdex/#up_msp/#up_mse
#   由调用方(bonus_held / bonus_armor)归零。
#   #up_mhp 的单位是 0.01%(1.5% -> 150)
#   ★ 2026-10-07 扩: ar/at/hp(硬化石: 护甲/韧性/生命)、cdex(冷却剂·Ω 长冷却开关)、
#     ms.pct/ms.every(魔力沸涌) 也走同一套"同系取最高" —— 这三样都是"本级的完整效果",
#     不是"在上一级基础上再加"。桶里**整条定义**都存着, 所以直接按字段读/减/加。
#   ★ 2026-10-07 二改: dmg/mana/cd 也收进来了(原先在 bonus_one 里无条件累加) ——
#     口径统一成一句: **同一个 series 只算最高 tier 那条, 不同 series 之间相加**。
# ============================================================

# 桶不存在就先建一个"空桶", 不然下面第一次 data get 会读不到(分数留旧值)
$execute unless data storage zx:work up_val."$(series)" run data modify storage zx:work up_val."$(series)" set value {tier:0,mm:0,mr:0,mh:0,mhp:0,ar:0,at:0,hp:0,cdex:0,aspd:0.0,tc:0,boil:0,nv:0,rg:0,ms:{pct:0,every:0}}

scoreboard players set #up_bt zx.meta 0
$execute store result score #up_bt zx.meta run data get storage zx:work up_val."$(series)".tier
# 没有更高就什么也不做(低阶被高阶盖掉了)
execute unless score #up_tier zx.meta > #up_bt zx.meta run return 0

# ① 减掉旧贡献
# ★ 2026-10-07 二改: dmg/mana/cd(乘区)也走这条桶 —— 以前它们在 bonus_one 里
#   无条件累加, 同系残留两条就变 α+β; 现在**同系只认最高 tier**, 跨系才相加。
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".dmg 100
scoreboard players operation #up_dmg zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mana 100
scoreboard players operation #up_mana zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".cd 100
scoreboard players operation #up_cd zx.meta -= #up_o zx.meta
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
# 硬化石: 护甲 / 韧性 / 生命
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".ar
scoreboard players operation #up_ar zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".at
scoreboard players operation #up_at zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".hp
scoreboard players operation #up_hp zx.meta -= #up_o zx.meta
# 冷却剂·Ω 的长冷却开关 / 魔力沸涌的阈值与间隔
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".cdex
scoreboard players operation #up_cdex zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".ms.pct
scoreboard players operation #up_msp zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".ms.every
scoreboard players operation #up_mse zx.meta -= #up_o zx.meta
# 神经衰弱: 攻击速度(aspd, 单位 0.01 —— 和乘区 dmg/mana/cd 同一套 ×100 定点)
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".aspd 100
scoreboard players operation #up_aspd zx.meta -= #up_o zx.meta

# ① 续: 最后一批四个"效果开关"(火炬 / 沸腾 / 夜视仪 / 再生), 同样减旧贡献
#    —— 它们是 0/1 开关, 同系只有一条, 减完再加回来就等于"只留当前生效那条"。
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".tc
scoreboard players operation #up_tc zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".boil
scoreboard players operation #up_boil zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".nv
scoreboard players operation #up_nv zx.meta -= #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".rg
scoreboard players operation #up_rg zx.meta -= #up_o zx.meta

# ② 整条定义换进桶
$data modify storage zx:work up_val."$(series)" set from storage zx:config updef."$(id)"

# ③ 加回新贡献
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".dmg 100
scoreboard players operation #up_dmg zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".mana 100
scoreboard players operation #up_mana zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".cd 100
scoreboard players operation #up_cd zx.meta += #up_o zx.meta
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
# 硬化石
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".ar
scoreboard players operation #up_ar zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".at
scoreboard players operation #up_at zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".hp
scoreboard players operation #up_hp zx.meta += #up_o zx.meta
# 冷却剂·Ω / 魔力沸涌
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".cdex
scoreboard players operation #up_cdex zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".ms.pct
scoreboard players operation #up_msp zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".ms.every
scoreboard players operation #up_mse zx.meta += #up_o zx.meta
# 神经衰弱: 攻击速度加回新贡献(和上面减旧那段一一对应)
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".aspd 100
scoreboard players operation #up_aspd zx.meta += #up_o zx.meta

# ③ 续: 四个效果开关加回新贡献(和上面那四段一一对应)
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".tc
scoreboard players operation #up_tc zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".boil
scoreboard players operation #up_boil zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".nv
scoreboard players operation #up_nv zx.meta += #up_o zx.meta
scoreboard players set #up_o zx.meta 0
$execute store result score #up_o zx.meta run data get storage zx:work up_val."$(series)".rg
scoreboard players operation #up_rg zx.meta += #up_o zx.meta

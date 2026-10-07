# ============================================================
# sweetdream:upgrade/armor_apply —— 把"穿着的盔甲上的升级"落到一个玩家身上
# ------------------------------------------------------------
# 【执行者】玩家(由 upgrade/second 以 @a 身份逐个调用)
# 【做两件事】
#   ① 魔力上限: 账本式 —— 只加减"目标值和已加值之间的差"(面板是一个数,
#      没有加成层, 不能每次直接加, 否则每过一秒就叠一次)。
#      换装/脱下时目标变小, 差值是负数, 自然就减回去了。
#   ② 每秒回魔: 直接 api/mana/add(和静脉泵一个口径), 并记进 zx.regen_extra,
#      这样 debug/stats 那一行"装备额外回魔"能把升级给的也算进去。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

function sweetdream:upgrade/api/bonus_armor

# ⓪ 效果开关(2026-10-08): 夜视仪 -> 常驻夜视; 生命提升·Ω -> 常态再生Ⅰ
#   ★ 放在最前面: 后面几步会调各种接口, zx:out 是全包共用的出口, 晚读可能被别人覆盖。
#   ★ 为什么给 12 秒而不是每秒续 1 秒: 每秒 effect give 会让状态图标一直闪,
#     而且换装的那一秒之后还有 11 秒残留 —— 残留时间必须短到"脱了就没",
#     又长到不至于每秒刷屏。12 秒是这两者的平衡点(和焱的抗火同一个口径)。
scoreboard players set #up_e zx.meta 0
execute store result score #up_e zx.meta run data get storage zx:out r.nv
execute if score #up_e zx.meta matches 1.. run function sweetdream:upgrade/api/nv_now
scoreboard players set #up_e zx.meta 0
execute store result score #up_e zx.meta run data get storage zx:out r.rg
execute if score #up_e zx.meta matches 1.. run function sweetdream:upgrade/api/rg_now

# ① 魔力上限: 目标值 - 已加值 = 这一秒该加减多少
scoreboard players set #up_target zx.meta 0
execute store result score #up_target zx.meta run data get storage zx:out r.mm
scoreboard players operation #diff zx.meta = #up_target zx.meta
scoreboard players operation #diff zx.meta -= @s zx.up_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:upgrade/api/max_mana_diff

# ② 每秒回魔
scoreboard players set #up_r zx.meta 0
execute store result score #up_r zx.meta run data get storage zx:out r.mr
execute if score #up_r zx.meta matches 1.. run function sweetdream:upgrade/api/regen_now

# ③ 护甲值 / 护甲韧性 / 最大生命值(硬化石, 2026-10-07 补)
#    和 ① 魔力上限同一套"账本式": 只加减 @s 上那笔账与目标值的差 ——
#    换装/脱下时目标变小, 差值是负数, 自然减回去。
#    面板没有"护甲/韧性"这两项(只有原版属性), 生命值则两边都要写(技能公式读面板)。
scoreboard players set #up_ar zx.meta 0
execute store result score #up_ar zx.meta run data get storage zx:out r.ar
scoreboard players operation #diff zx.meta = #up_ar zx.meta
scoreboard players operation #diff zx.meta -= @s zx.up_armor
execute unless score #diff zx.meta matches 0 run function sweetdream:upgrade/api/armor_add

scoreboard players set #up_at zx.meta 0
execute store result score #up_at zx.meta run data get storage zx:out r.at
scoreboard players operation #diff zx.meta = #up_at zx.meta
scoreboard players operation #diff zx.meta -= @s zx.up_at
execute unless score #diff zx.meta matches 0 run function sweetdream:upgrade/api/tough_add

scoreboard players set #up_hp zx.meta 0
execute store result score #up_hp zx.meta run data get storage zx:out r.hp
scoreboard players operation #diff zx.meta = #up_hp zx.meta
scoreboard players operation #diff zx.meta -= @s zx.up_hp
execute unless score #diff zx.meta matches 0 run function sweetdream:upgrade/api/hp_add

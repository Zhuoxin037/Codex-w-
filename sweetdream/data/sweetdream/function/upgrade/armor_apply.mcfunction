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

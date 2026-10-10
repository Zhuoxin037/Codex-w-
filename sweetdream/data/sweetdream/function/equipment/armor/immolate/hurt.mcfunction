# ============================================================
# sweetdream:equipment/armor/immolate/hurt —— 焚舟·攻击生物后
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/immolate_hurt
#   trigger: player_hurt_entity -> 玩家打到实体时执行, @s = 玩家
# 【三段效果】
#   ① 未燃烧的目标: 若烈空已经 200 -> 进入衰减模式(lk_mode=1)
#   ② 两件套 + 目标有「流火」或「夜火」: +20 烈空（同一只只加一次）
#   ③ 两件套 + 烈空正好 200 + 没有在 buff 里 -> 给 +100 上限, 持续 20 秒
# 【目标怎么找】进度只给“打到了”, 不给受害者实体;
#   所以从视线前方找最近的“非玩家实体”。
#   ⚠️ 这里**不能**用 !#sweetdream:no_damage 去筛 —— 那个表把盔甲架/训练
#   人偶也排掉了, 结果就是“打人偶完全不触发”, 测试根本测不出来。
#   逻辑判定只需要“前面最近的是谁”, 真正打伤害的地方才该用排除表。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/immolate_hurt
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] run return 0

# 找目标: 1.5 格 -> 3 格 -> 5 格, 都找不到就按“未燃烧”处理
#   用 hit_scan_exclude 排掉物品/箭/展示实体, 但**保留盔甲架/训练人偶**。
tag @e[tag=zx.im_t] remove zx.im_t
execute anchored eyes positioned ^ ^ ^1.5 run tag @e[type=!#sweetdream:hit_scan_exclude,distance=..1.5,sort=nearest,limit=1] add zx.im_t
execute unless entity @e[tag=zx.im_t,limit=1] anchored eyes positioned ^ ^ ^3.0 run tag @e[type=!#sweetdream:hit_scan_exclude,distance=..2.5,sort=nearest,limit=1] add zx.im_t
execute unless entity @e[tag=zx.im_t,limit=1] anchored eyes positioned ^ ^ ^4.5 run tag @e[type=!#sweetdream:hit_scan_exclude,distance=..3.5,sort=nearest,limit=1] add zx.im_t

# ② 两件套 + 目标带流火/夜火 -> +20（同一只只加一次）
scoreboard players set #im_marked zx.meta 0
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] if items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] if entity @e[tag=zx.im_t,tag=zx.status.liuhuo,limit=1] run scoreboard players set #im_marked zx.meta 1
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] if items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] if entity @e[tag=zx.im_t,tag=zx.status.yehuo,limit=1] run scoreboard players set #im_marked zx.meta 1
execute if score #im_marked zx.meta matches 1 run scoreboard players add @s zx.im_set20 1
execute if score #im_marked zx.meta matches 1 run scoreboard players add @s zx.lk 20
execute if score @s zx.lk matches 201.. run scoreboard players set @s zx.lk 200

# ③ 两件套 + 刚好满 200 + 不在 buff 中 -> +100 上限 20 秒
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] if items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] if score @s zx.lk matches 200 if score @s zx.im_buff_mk matches 0 run function sweetdream:equipment/armor/immolate/buff_on

# ① 目标当前没有燃烧 + 烈空 200 -> 进入衰减模式
#    找不到目标(#im_t 不存在)也按“未燃烧”处理, 免得空挥完全不触发。
scoreboard players set #im_f zx.meta 0
execute if entity @e[tag=zx.im_t,limit=1] store result score #im_f zx.meta run data get entity @e[tag=zx.im_t,limit=1] Fire
execute if score #im_f zx.meta matches ..0 if score @s zx.lk matches 200 run scoreboard players set @s zx.lk_mode 1

tag @e[tag=zx.im_t] remove zx.im_t

# ============================================================
# sweetdream:equipment/armor/immolate/tick —— 焚舟·每刻推「烈空」
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick
#   execute as @a[tag=zx.im_on] at @s run ...
# 【两件最容易写错的事】
#   ① “自身 12 格内有生物处于燃烧状态”不是看玩家自己身上有没有火,
#      旧版写成 `if entity @s[tag=zx.im_burn]` -> @s 是玩家, 永远不成立,
#      所以烈空永远不涨。现在直接问“12 格内有没有 Fire>0 的生物”。
#   ② 衰减到 0 时必须把 lk_mode 关掉, 否则下一 tick 会变成 -1,
#      再被夹回 0, 又满足 `matches 0` 的 burn_ray 条件, 变成每刻无限触发。
# ============================================================

scoreboard players add @s zx.lk 0
scoreboard players add @s zx.lk_mode 0

# 脱装那一秒 tag 可能还没被 second 摘掉, 这里再兜底一次
execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] run return 0

# 积攒: 每刻 +1（只在非衰减模式）
#   ⚠️ 1.21.5 的实体选择器 nbt= 不接受 `Fire:1..` 这种范围写法,
#   写了会导致整个 tick 函数加载失败。这里改成逐实体 data get Fire:
#   check_burn 在生物身份下把 #im_burn_found 置 1, 回到玩家身份后再判断。
scoreboard players set #im_burn_found zx.meta 0
# 检测扫描用 hit_scan_exclude: 保留盔甲架/训练人偶, 否则人偶在烧也检测不到。
execute as @e[type=!#sweetdream:hit_scan_exclude,distance=..12] at @s run function sweetdream:equipment/armor/immolate/check_burn
execute if score @s zx.lk_mode matches 0 if score #im_burn_found zx.meta matches 1 run scoreboard players add @s zx.lk 1
execute if score @s zx.lk matches 201.. run scoreboard players set @s zx.lk 200

# 衰减: 每刻 -1；到 0 的那一 tick 允许触发最后一次 burn_ray, 然后关掉衰减
execute if score @s zx.lk_mode matches 1 run scoreboard players remove @s zx.lk 1
execute if score @s zx.lk matches ..-1 run scoreboard players set @s zx.lk 0
# 每减少 20 点触发一次: 用取模判断(1.21.5 的 matches 不支持逗号列表)
#   180/160/.../0 这些值都满足 lk % 20 == 0; 到 0 时下面会把 mode 关掉, 不会重复触发。
scoreboard players operation #im_mod zx.meta = @s zx.lk
scoreboard players operation #im_mod zx.meta %= #20 zx.meta
execute if score @s zx.lk_mode matches 1 if score #im_mod zx.meta matches 0 run function sweetdream:equipment/armor/immolate/burn_ray
execute if score @s zx.lk matches ..0 run scoreboard players set @s zx.lk_mode 0

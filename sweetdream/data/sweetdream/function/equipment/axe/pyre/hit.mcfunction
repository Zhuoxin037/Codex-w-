# ============================================================
# sweetdream:equipment/axe/pyre/hit —— 葬火: 「下一次攻击」引爆(平A钩子)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/pyre_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文】"使用后下一次攻击额外对自身 2 格内的全部生物造成 X 点伤害并使其燃烧
#   X×0.05 秒。2 秒后再对自身 5 格范围内的全部生物造成 X×0.5 点伤害。"
# 【★ 四要素 ★】
#   ① 触发: 平A(且手里是葬火、且已挂上状态)。
#   ② 目标范围: 自身 2 格内的**全部**生物(不是被击的那一只)。
#   ③ 次数: 这一下打完 1 次; 之后清"已就绪"、排 2 秒后的第二段。
#   ④ 时长: 燃烧 X×0.05 秒; 2 秒倒计时 = zx.py_d 40(core/tick 推, 见 tick)。
# 【★ 按游戏刻去重 ★】player_hurt_entity 每命中一只触发一次, 横扫会跑 N 遍。
#   文案是"下一次攻击" -> 一次平A算一次, 所以按刻去重(每件一个计分项 zx.py_lt)。
# 【燃烧时长】X×0.05 秒 × 20 tick/秒 = **X tick**(直接写进 Fire)。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/pyre_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是葬火
scoreboard players set #py_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["pyre"]}] run scoreboard players set #py_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["pyre"]}] run scoreboard players set #py_ok zx.meta 1
execute unless score #py_ok zx.meta matches 1 run return 0

# ★ 按游戏刻去重(每次攻击算一次, 不按命中数)
execute if score @s zx.py_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.py_lt = #now manacore.meta

# 没挂状态 -> 什么都不做
execute unless score @s zx.py_rdy matches 1 run return 0
scoreboard players set @s zx.py_rdy 0

# ① X 点伤害 -> 自身 2 格内的全部生物
scoreboard players operation #py_x zx.meta = @s zx.py_x
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",damage:0.0}
execute store result storage zx:in arg.damage double 1 run scoreboard players get #py_x zx.meta
execute at @s run function sweetdream:api/damage

# ② 使其燃烧 X×0.05 秒 = X tick(直接写 Fire)
execute at @s as @e[type=!#sweetdream:no_damage,distance=..2] store result entity @s Fire short 1 run scoreboard players get #py_x zx.meta

# ③ 排 2 秒后(40 tick)第二段: 自身 5 格内 X×0.5
scoreboard players set @s zx.py_d 40

# ④ 表现
execute at @s run particle minecraft:lava ~ ~0.5 ~ 1.4 0.3 1.4 0.02 24 normal
execute at @s run playsound minecraft:entity.blaze.burn player @a ~ ~ ~ 1.0 0.9

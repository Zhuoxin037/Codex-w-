# ============================================================
# sweetdream:equipment/sword/tinder/hit —— 火种 · 每次攻击的钩子(按刻去重)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/tinder_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   "「火种」为燃烧状态时，攻击生物时将会对其 2 格内的全部生物造成相当于自身当前
#    魔力值 ×0.1 的伤害，之后使未处于燃烧状态的生物燃烧 5 秒并熄灭该武器。为熄灭
#    状态时，攻击生物后会对自身造成相当于自身最大生命值 ×0.3 的伤害并使「火种」
#    变为燃烧状态。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 攻击生物(每次攻击 -> 按游戏刻去重; 且因为"熄灭"是状态, 不去重会
#      在横扫多命中时熄灭/点燃反复横跳)。
#   ② 目标范围: 燃烧态 -> "被击者 2 格内的**全部**生物"; 熄灭态 -> **自身**。
#   ③ 次数: 一次攻击一次(两态各自结算)。
#   ④ 时长: 燃烧 5 秒(Fire=100 tick); "熄灭该武器"/"变为燃烧状态" 是状态机翻转。
# 【状态存哪】玩家计分项 zx.td_on(1=燃烧 / 0=熄灭), 由本文件与 second 读写。
# 【数值改哪】倍率 0.1 = burn 的 other_mul; 半径 2 = burn 的选择器; 燃烧 5 秒 = burn 的 Fire:100;
#   反噬倍率 0.3 = dark 的 ×3/1000。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/tinder_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是火种才继续
scoreboard players set #td_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_sword[custom_data~{zx:["tinder"]}] run scoreboard players set #td_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_sword[custom_data~{zx:["tinder"]}] run scoreboard players set #td_ok zx.meta 1
execute unless score #td_ok zx.meta matches 1 run return 0

# 【★ "每次攻击"去重 ★】同刻已结算过就退出
execute if score @s zx.td_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.td_lt = #now manacore.meta

# 两态分流
execute if score @s zx.td_on matches 1 run function sweetdream:equipment/sword/tinder/burn
execute unless score @s zx.td_on matches 1 run function sweetdream:equipment/sword/tinder/dark

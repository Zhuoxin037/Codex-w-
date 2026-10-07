# ============================================================
# sweetdream:equipment/axe/thunderclap/hit —— 威霆: 攻击生物后(平A钩子)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/thunderclap_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   "自身攻击生物后立即消耗全部「天煌」并消耗等量的魔力，之后在其位置生成一个半径 6 格的
#    术阵，在该术阵结束前不能再生成另一个术阵。在该术阵内的生物每受到一次攻击则立即有 X
#    道闪电对其造成伤害，每道闪电的伤害为自身最大魔力值 ×0.1。生物每受到 10 次雷击则损失
#    自身 10% 最大生命值，共持续 X×2 秒（X 为「天煌」×0.005）。"
# 【★ 四要素 ★】
#   ① 触发: 平A命中(手里是威霆)。
#   ② 目标范围: 被击的那一只(生成术阵于其位置); 之后"在术阵(半径 6)内的生物"。
#   ③ 次数: 一次攻击 —— 有术阵就落雷一次; 没术阵就开一个。
#   ④ 时长: 术阵持续 X×2 秒; 同期只能有一个(zx.tc_on + 术阵 marker)。
# 【★ 按游戏刻去重 ★】player_hurt_entity 每命中一只触发一次 -> 一次平A算一次(zx.tc_lt)。
# 【★ 解读(请核对) ★】
#   · "在该术阵内的生物每受到一次攻击" 我按"**持威霆者**的攻击"实现(用同一把武器打术阵里的怪)。
#   · 威霆**没有主动技能**, 不开右键 -> give 里没有 consumable / skill 字段(已确认)。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/thunderclap_hit

# 武器门控: 主手或副手是威霆
scoreboard players set #tc_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["thunderclap"]}] run scoreboard players set #tc_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["thunderclap"]}] run scoreboard players set #tc_ok zx.meta 1
execute unless score #tc_ok zx.meta matches 1 run return 0

# ★ 按游戏刻去重
execute if score @s zx.tc_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.tc_lt = #now manacore.meta

# 定位被击的那一只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ① 已经有术阵 -> 在术阵内落雷(见 bolt)
execute if score @s zx.tc_on matches 1 run function sweetdream:equipment/axe/thunderclap/bolt
execute if score @s zx.tc_on matches 1 run tag @e[tag=zx.victim,distance=0..] remove zx.victim
execute if score @s zx.tc_on matches 1 run return 0

# ② 没术阵 + 天煌 >0 -> 消耗天煌与等量魔力, 在被击者处开一个术阵
execute if score @s zx.tc_n matches ..0 run return 0
function sweetdream:equipment/axe/thunderclap/open
tag @e[tag=zx.victim,distance=0..] remove zx.victim

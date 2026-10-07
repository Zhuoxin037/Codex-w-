# ============================================================
# internal/debug/selftest_run —— 框架自检(4 个用例)
# ------------------------------------------------------------
# 【宏参数】索引条目 {uuid,slot}
# 【做法】先备份该玩家记录 -> 写入受控测试数据 -> 逐项断言 -> 还原。
# 【用例】
#   1a. 攻击力通道: base_attack=10, attack_mul=2, 独立乘区=1.5, 固定伤害=5
#                 期望 (10x2+5)x1.5 = 37.5 -> 定点后 37500
#   1b. 三通道相加: 最大魔力=100 x0.5 + 攻击力 10x2 + 固定 5 = 75 -> 75000
#   2. 冷却    : 起 40 tick 冷却, 立刻查剩余应为 40, 然后清掉
#   3. 术阵    : 创建 1 个术阵后数量应为 1
#   4. 术阵上限: 连开 4 个(默认上限 3), 第 4 个必须被拒绝(success=0)
# 【怎么读结果】HUD 会把定点值(真实值 x1000)直接打印, 对照注释即可。
# 【安全】最后一行用备份整份覆盖回来, 自检不会污染玩家数据。
# ============================================================
$data modify storage manacore:selftest backup set from storage manacore:players "$(uuid)"
tellraw @s [{"text":"==== ManaCore 自检 ====","color":"aqua","bold":true}]
$tellraw @s [{"text":"测试对象: ","color":"gray"},{"text":"$(uuid)","color":"white"}]

# --- 用例1: 基础攻击力 / 技能倍率 / 独立乘区 ---
$data modify storage manacore:players "$(uuid)".stats.base_attack set value 10.0
$data modify storage manacore:players "$(uuid)".stats.max_health set value 20.0
$data modify storage manacore:work a set value {uuid:"$(uuid)",base_attack:-1.0,attack_mul:2.0,independent_multiplier:1.5,custom_damage:5.0,health_ratio:0.0}
function manacore:internal/damage/calc with storage manacore:work a
execute store result score #t manacore.math run data get storage manacore:out r.damage 1000
tellraw @s [{"text":"1a. 攻击力通道(期望 37500): ","color":"gray"},{"score":{"name":"#t","objective":"manacore.math"}}]

# --- 用例1b: 三通道相加(最大魔力 x0.5 + 攻击力 x2 + 固定 5) ---
#   最大魔力设 100 -> 100x0.5 = 50; 攻击力 10x2 = 20; +5 = 75 (期望 75000)
$data modify storage manacore:players "$(uuid)".stats.max_mana set value 100.0
$data modify storage manacore:work a set value {uuid:"$(uuid)",max_mana_mul:0.5,attack_mul:2.0,custom_damage:5.0,independent_multiplier:1.0}
function manacore:internal/damage/calc with storage manacore:work a
execute store result score #t manacore.math run data get storage manacore:out r.damage 1000
tellraw @s [{"text":"1b. 三通道相加(期望 75000): ","color":"gray"},{"score":{"name":"#t","objective":"manacore.math"}}]

# --- 用例2: 冷却 ---
$data modify storage manacore:players "$(uuid)".stats.cooldown_reduction set value 0.0
$data modify storage manacore:work a set value {uuid:"$(uuid)",skill:"manacore:selftest",cooldown:40,cooldown_seconds:0.0,reduce:0b}
function manacore:internal/cooldown/start with storage manacore:work a
$data modify storage manacore:work a set value {uuid:"$(uuid)",skill:"manacore:selftest"}
function manacore:internal/cooldown/check with storage manacore:work a
execute store result score #t manacore.math run data get storage manacore:out r.remaining
tellraw @s [{"text":"2. 冷却剩余(期望 40): ","color":"gray"},{"score":{"name":"#t","objective":"manacore.math"}}]
function manacore:internal/cooldown/reset with storage manacore:work a

# --- 用例3: 术阵 ---
$data modify storage manacore:work a set value {uuid:"$(uuid)",id:"manacore:selftest",type:"test",duration:40,duration_seconds:0.0}
function manacore:internal/formation/create with storage manacore:work a
$data modify storage manacore:work a set value {uuid:"$(uuid)"}
function manacore:internal/formation/count with storage manacore:work a
execute store result score #t manacore.math run data get storage manacore:out r.count
tellraw @s [{"text":"3. 术阵数量增量(期望 1): ","color":"gray"},{"score":{"name":"#t","objective":"manacore.math"}}]

# --- 用例4: 术阵上限 ---
$data modify storage manacore:work a set value {uuid:"$(uuid)",id:"manacore:selftest2",type:"test",duration:40,duration_seconds:0.0}
function manacore:internal/formation/create with storage manacore:work a
$data modify storage manacore:work a set value {uuid:"$(uuid)",id:"manacore:selftest3",type:"test",duration:40,duration_seconds:0.0}
function manacore:internal/formation/create with storage manacore:work a
$data modify storage manacore:work a set value {uuid:"$(uuid)",id:"manacore:selftest4",type:"test",duration:40,duration_seconds:0.0}
function manacore:internal/formation/create with storage manacore:work a
$data modify storage manacore:work a set value {uuid:"$(uuid)",id:"manacore:selftest5",type:"test",duration:40,duration_seconds:0.0}
function manacore:internal/formation/create with storage manacore:work a
execute store result score #t manacore.math run data get storage manacore:out r.success
tellraw @s [{"text":"4. 第4个术阵是否被上限拒绝(期望 success=0): ","color":"gray"},{"score":{"name":"#t","objective":"manacore.math"}}]

# --- 还原 ---
$data modify storage manacore:players "$(uuid)" set from storage manacore:selftest backup
execute if data storage manacore:selftest backup run data remove storage manacore:selftest backup
tellraw @s [{"text":"自检结束, 数据已还原","color":"green"}]

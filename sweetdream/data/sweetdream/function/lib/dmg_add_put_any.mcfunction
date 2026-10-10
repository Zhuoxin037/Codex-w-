# ============================================================
# sweetdream:lib/dmg_add_put_any —— 往"加算池"里加一份"不挑口径"的百分比
# ------------------------------------------------------------
# 【宏参数】无(读 zx:work put.pct, 和 lib/dmg_add_put 的出参口径一致)
# 【和 lib/dmg_add_put 的区别】
#   dmg_add_put  : 调用方**指定**写哪条通道("挑口径"用: 漫步只写 mm、炽天使只写 atk)
#   dmg_add_put_any: 由本函数**自己挑**那条"本次技能真正用到的通道", 只写一条
# 【★★ 为什么必须有它(修 F14)★★】
#   文案写"技能伤害 +X%"的几件(愿景升级 / 共振 / 桂冠)口径是"不挑通道",
#   旧写法是**三条通道各写一份 X**。单通道技能没问题(只有用到的那条会被
#   lib/dmg_add_apply 计入); 但**多通道技能**(mm + atk 各出一部分伤害)会让
#   同一份 X 被算两次: 总伤害 ×(1+2X) —— 一个 +30% 变成 +60%(报告 F14)。
#   现在读 lib/dmg_ch 拍下的通道快照 zx:work ch, 只写**第一条非 0 的通道**:
#     多通道技能下总伤害 ×(1+X) —— 与"逐通道同幅增伤再求和"数值完全一致
#     (100×1.3 + 10×1.3 = 110×1.3 = 143, 正是报告给的期望值)。
# 【为什么"只写一条"就够】同一份百分比在总伤害上多乘几次没有意义; 语义是
#   "本次技能伤害 +X%", 不是"每条通道各 +X%"。
# 【兜底】三条通道全 0(异常 / 直接调 internal 没走 calc) -> 写 mm,
#   和旧行为一致(那时 dmg_add_apply 也一条都不累加)。
# 【通道优先级】mm > atk > oth, 与 lib/dmg_add_apply 的读取顺序一致, 只是取首条。
# ============================================================

# --- ① 最大魔力值通道 ---
data modify storage zx:work put.ch set value "mm"
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.max_mana_mul 100
execute if score #u zx.meta matches 1.. run function sweetdream:lib/dmg_add_put with storage zx:work put
execute if score #u zx.meta matches 1.. run return 0

# --- ② 基础攻击力通道 ---
data modify storage zx:work put.ch set value "atk"
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.attack_mul 100
execute if score #u zx.meta matches 1.. run function sweetdream:lib/dmg_add_put with storage zx:work put
execute if score #u zx.meta matches 1.. run return 0

# --- ③ 其他通道(当前魔力结算那类) ---
data modify storage zx:work put.ch set value "oth"
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.other_mul 100
execute if score #u zx.meta matches 1.. run function sweetdream:lib/dmg_add_put with storage zx:work put
execute if score #u zx.meta matches 1.. run return 0

# --- ④ 兜底: 三条都没用到 -> 写 mm(与旧行为等价) ---
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put

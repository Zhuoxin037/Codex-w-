# ============================================================
# sweetdream:equipment/staff/triad/next_form —— 切到下一把(冰斧→热刀→重枪→冰斧)
# ------------------------------------------------------------
# 【执行者】玩家 @s
# 【★ 循环用"加完再钳"而不是取模 ★】计分板没有现成的取模写法能一步到位,
#   而形态只有 3 档: +1 后若 ≥3 就归 0, 与 %3 等价且一眼看得懂。
# 【★ 切换**不刷新**强化的 15 秒 ★】文案: "本效果持续 15 秒, 结束后切回冰斧" ——
#   15 秒是**这一次技能**的总时长, 中途换形态只是提前换武器, 不该顺带续命。
# 【为什么不在切换时清 zx.tri_next】那是"下一次攻击"的状态位, 属于**当前形态**遗留
#   的效果(比如重枪埋下的"下次为空"), 按文案就该留着; 攻击用掉时 attack 会清。
# ============================================================

scoreboard players add @s zx.tri_form 1
execute if score @s zx.tri_form matches 3.. run scoreboard players set @s zx.tri_form 0

# ① 把**手上那把武器**改成新形态的名字(主手 + 副手都改; 只改 item_name, 其余组件原样)
function sweetdream:equipment/staff/triad/rename

# ② 提示 + 表现
execute if score @s zx.tri_form matches 0 run tellraw @s [{"text":"切换至「很冰的斧」","color":"gold"}]
execute if score @s zx.tri_form matches 1 run tellraw @s [{"text":"切换至「很热的刀」","color":"red"}]
execute if score @s zx.tri_form matches 2 run tellraw @s [{"text":"切换至「很重的枪」","color":"gray"}]
execute at @s run particle minecraft:enchant ~ ~1 ~ 0.6 0.6 0.6 0.05 20 normal

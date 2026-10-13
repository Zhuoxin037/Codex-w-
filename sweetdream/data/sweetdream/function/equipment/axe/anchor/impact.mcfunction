# ============================================================
# sweetdream:equipment/axe/anchor/impact —— 沉锚落点结算
# ------------------------------------------------------------
# 【谁调用它】anchor/cast ⑧: execute at @e[tag=zx.an_tgt] run function ...
# 【执行者】施法者(玩家)  【位置】目标(锚的落点)
# 【做什么】① 圈出落点 2 格内全部生物  ② 打 基础攻击力 ×5  ③ 全部向上击飞
# 【★ 击飞方向】2026-10-12 用户拍板: "往上击飞"(背离施法者的那种叫"击退", 不要)。
#   方向固定 = 正上方, 所以直接用 Motion; 不用 iridescent/eff_3 那套 tp(那套是为了"朝某方向")。
# ============================================================

# ① 圈出落点 2 格内
tag @e[tag=zx.an_hit] remove zx.an_hit
tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.an_hit

# ② 伤害 = 释放者基础攻击力 ×5
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.an_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
function sweetdream:api/damage

# ③ 向上击飞(同 hit: 用户 2026-10-12 要求"往上", 不要"背离施法者"的击退)
#   0.55 ≈ 弹起 2 格 —— 与文案"击飞2格"对上; 技能比被动那下抬得更高, 能看出是一次"炸飞"。
execute as @e[tag=zx.an_hit,distance=0..] run data modify entity @s Motion set value [0.0d,0.55d,0.0d]

# ④ 落点表现 + 收尾
execute at @s run particle minecraft:cloud ~ ~0.3 ~ 1.0 0.3 1.0 0.05 24 normal
execute at @s run particle minecraft:enchanted_hit ~ ~0.6 ~ 1.0 0.4 1.0 0.1 20 normal
execute at @s run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.5 1.4
execute at @s run playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.5 1.6
tag @e[tag=zx.an_hit] remove zx.an_hit

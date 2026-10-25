# ============================================================
# sweetdream:equipment/axe/anchor/impact —— 沉锚落点结算
# ------------------------------------------------------------
# 【谁调用它】anchor/pull_end_go: execute at <目标> run function ...
# 【执行者】施法者(玩家)  【位置】目标(锚的落点)
# 【做什么】① 圈出落点 N 格内全部生物  ② 打 基础攻击力 ×N  ③ 全部向上击飞  ④ 缓慢  ⑤ 自身抗性
# 【★ 击飞方向】2026-10-12 用户拍板: "往上击飞"(背离施法者的那种叫"击退", 不要)。
#   方向固定 = 正上方, 所以直接用 Motion; 不用 iridescent/eff_3 那套 tp(那套是为了"朝某方向")。
# 【★ 超限分档(2026-10-23 批 K6) ★】zx.anc_ol 由 cast ⓪.6 拍好, 牵引全程 @s 不变 ⇒ 这里读得到。
#   半径 2→5 / ×5→×8 / 击飞 2→3 格 / 额外 5 秒缓慢Ⅳ + 自身 8 秒抗性提升Ⅳ。
#   击飞初速: 弹起高度 h = v²/(2g), g≈0.08 ⇒ 2 格要 0.55(原值), 3 格要 √(2×0.08×3)=0.693。
# ============================================================

# ⓪ 计分项"没分数 ≠ 0" —— 先补一个 0, 否则两条分档都不成立、一个目标都圈不到
scoreboard players add @s zx.anc_ol 0

# ① 圈出落点 N 格内: 普通 2 / 超限 5
tag @e[tag=zx.an_hit] remove zx.an_hit
execute if score @s zx.anc_ol matches 0 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.an_hit
execute if score @s zx.anc_ol matches 1.. run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.an_hit

# ② 伤害 = 释放者基础攻击力 ×5 / 超限 ×8
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0}
execute if score @s zx.anc_ol matches 1.. run data modify storage manacore:in arg.attack_mul set value 8.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.an_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
function sweetdream:api/damage

# ③ 向上击飞(同 hit: 用户 2026-10-12 要求"往上", 不要"背离施法者"的击退)
#   普通 0.55 ≈ 弹起 2 格; 超限 0.69 ≈ 弹起 3 格。
execute if score @s zx.anc_ol matches 0 as @e[tag=zx.an_hit,distance=0..] run data modify entity @s Motion set value [0.0d,0.55d,0.0d]
execute if score @s zx.anc_ol matches 1.. as @e[tag=zx.an_hit,distance=0..] run data modify entity @s Motion set value [0.0d,0.69d,0.0d]

# ③.5 超限: 5 秒缓慢Ⅳ(amplifier 3)
execute if score @s zx.anc_ol matches 1.. as @e[tag=zx.an_hit,distance=0..] run effect give @s minecraft:slowness 5 3 true

# ③.6 超限: 自身 8 秒抗性提升Ⅳ(amplifier 3)
execute if score @s zx.anc_ol matches 1.. run effect give @s minecraft:resistance 8 3 true

# ④ 落点表现 + 收尾
execute if score @s zx.anc_ol matches 1.. run particle minecraft:cloud ~ ~0.3 ~ 2.4 0.3 2.4 0.05 40 normal
execute if score @s zx.anc_ol matches 1.. run particle minecraft:enchanted_hit ~ ~0.6 ~ 2.4 0.4 2.4 0.1 36 normal
execute if score @s zx.anc_ol matches 1.. run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.6 1.1
execute if score @s zx.anc_ol matches 0 run particle minecraft:cloud ~ ~0.3 ~ 1.0 0.3 1.0 0.05 24 normal
execute if score @s zx.anc_ol matches 0 run particle minecraft:enchanted_hit ~ ~0.6 ~ 1.0 0.4 1.0 0.1 20 normal
execute if score @s zx.anc_ol matches 0 run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.5 1.4
execute at @s run playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.5 1.6
tag @e[tag=zx.an_hit] remove zx.an_hit

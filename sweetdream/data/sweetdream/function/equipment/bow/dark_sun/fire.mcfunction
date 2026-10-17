# ============================================================
# sweetdream:equipment/bow/dark_sun/fire —— 「黯日」结算(宏 {target, shooter, uuid})
# ------------------------------------------------------------
# 【执行者】射手(玩家), 位置/朝向 = 射手自己(apply 用 as/at 送进来)
# 【文案】每次射击命中生物后, 额外造成一次相当于自身当前魔力值 ×0.12 的伤害,
#   并使其附加「夜火」和「流火」。
#   若其已附有「流火」则上述伤害提高 30%; 若该目标在命中前已附有「夜火」则上述
#   伤害提高 50%(独立乘区), 并向命中位置 6 格内最近的四个其他生物释放一枚影矢。
#   该效果 20 秒内最多触发一次。
# 【★ 两个"已附有"都按**命中前**算(2026-10-15 用户拍板) ★】
#   文案后半句明写"在命中前已附有夜火"; 前半句若按"刚附加的流火"算就恒真、
#   30% 永远吃满 = 白写 ⇒ 一并按命中前快照(坑 123: 改状态前先拍快照)。
# 【★ 30% 折进系数、50% 走独立乘区 ★】文案只给 50% 标了"独立乘区" ⇒
#   30% 折进 other_mul(0.12 -> 0.156), 50% 交给 calc 的 independent_multiplier(=1.5)。
#   口径与「启示录」的"最后一次灾示伤害提高 50%"("提高 N%"折进系数)一致。
# 【★ 命中位置要先存 ★】影矢以"命中位置"为圆心, 而受害者可能被这一段伤害打死;
#   实体一旦移除, `at @e[tag=zx.ds_v]` 就取不到坐标了 ⇒ 结算**之前**先把坐标
#   落在一个 marker 上。
# ============================================================

# ⓪ 受害者还在吗
execute unless entity @e[tag=zx.ds_v,distance=0..,limit=1] run return 0

# ① 节流: **整段** 20 秒(2026-10-15 用户拍板)。
#   ★ 先 `add 0` 把没分数的玩家补成 0 —— 计分项"没分数"时 `if score` 判不成立。
scoreboard players add @s zx.ds_gate 0
execute if score @s zx.ds_gate > #now manacore.meta run return 0
scoreboard players operation @s zx.ds_gate = #now manacore.meta
scoreboard players operation @s zx.ds_gate += #400 zx.meta

# ② 拍"命中前"状态快照(挂受害者身上, 坑 123) + 记下"命中位置"
tag @e[tag=zx.ds_hadl,distance=0..] remove zx.ds_hadl
tag @e[tag=zx.ds_hady,distance=0..] remove zx.ds_hady
execute as @e[tag=zx.ds_v,distance=0..,limit=1] if entity @s[tag=zx.status.liuhuo] run tag @s add zx.ds_hadl
execute as @e[tag=zx.ds_v,distance=0..,limit=1] if entity @s[tag=zx.status.yehuo] run tag @s add zx.ds_hady
kill @e[tag=zx.ds_pos,distance=0..]
execute at @e[tag=zx.ds_v,limit=1] run summon minecraft:marker ~ ~ ~ {Tags:["zx.ds_pos"]}

# ③ 额外伤害 = 当前魔力值 ×0.12; 命中前带流火 -> 系数 ×1.3; 命中前带夜火 -> 整段 ×1.5
data modify storage manacore:in arg set value {uuid:"",other_mul:0.12,independent_multiplier:1.0}
execute if entity @e[tag=zx.ds_hadl,distance=0..,limit=1] run data modify storage manacore:in arg.other_mul set value 0.156
execute if entity @e[tag=zx.ds_hady,distance=0..,limit=1] run data modify storage manacore:in arg.independent_multiplier set value 1.5
data modify storage manacore:in arg.uuid set from storage zx:work ds.uuid
function manacore:api/damage/calc
data modify storage zx:work ds.dmg set value 0.0
data modify storage zx:work ds.dmg set from storage manacore:out r.damage
# 诊断锚: #ds_dbg8 = 主目标这一段伤害(×1000);
#           #ds_dbg9 = 命中前状态位(1 = 带流火 / 2 = 带夜火 / 3 = 两个都带 —— 用它核对
#           30% / 50% / 影矢 有没有按快照走)
scoreboard players set #ds_dbg8 zx.meta 0
execute store result score #ds_dbg8 zx.meta run data get storage zx:work ds.dmg 1000
scoreboard players set #ds_dbg9 zx.meta 0
execute if entity @e[tag=zx.ds_hadl,distance=0..,limit=1] run scoreboard players add #ds_dbg9 zx.meta 1
execute if entity @e[tag=zx.ds_hady,distance=0..,limit=1] run scoreboard players add #ds_dbg9 zx.meta 2
execute store result storage zx:work ds.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work ds.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work ds.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work ds.u3 int 1 run data get entity @s UUID[3]

# ④ 打出这一段伤害(带射手归属)
execute as @e[tag=zx.ds_v,distance=0..,limit=1] at @s run function sweetdream:equipment/bow/dark_sun/strike

# ⑤ 使其附加「夜火」和「流火」(这是"附着"不是"消耗" ⇒ 走通用接口 tag/mark)
data modify storage zx:work ic set value {target:"@e[tag=zx.ds_v]",mark:"yehuo"}
function sweetdream:tag/mark with storage zx:work ic
data modify storage zx:work ic set value {target:"@e[tag=zx.ds_v]",mark:"liuhuo"}
function sweetdream:tag/mark with storage zx:work ic

# ⑥ 命中前带夜火 -> 影矢(4 发, 打命中位置周围最近的其他生物)
execute if entity @e[tag=zx.ds_hady,distance=0..,limit=1] run function sweetdream:equipment/bow/dark_sun/volley

# ⑦ 收尾
kill @e[tag=zx.ds_pos,distance=0..]
tag @e[tag=zx.ds_hadl,distance=0..] remove zx.ds_hadl
tag @e[tag=zx.ds_hady,distance=0..] remove zx.ds_hady
tag @e[tag=zx.ds_v,distance=0..] remove zx.ds_v

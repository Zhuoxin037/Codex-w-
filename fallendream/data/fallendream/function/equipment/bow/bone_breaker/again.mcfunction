# ============================================================
# fallendream:equipment/bow/bone_breaker/again —— 碎刀还在场上时又射了一箭
# ------------------------------------------------------------
# 【执行者】射手(玩家)   【入参】zx:work bbk {u0,u1,u2,u3,uid,ol}
# 【文案·原版】没有这段 —— 有碎刀就什么都不发生(只提示)。
# 【文案·超限】"「碎刀」持续期间若自身再次射击则「碎刀」的刀刃 +1 且持续时间重置，
#   每个「碎刀」最多触发 2 次该效果。"
#   ⇒ 追加 2 次为上限(3 → 4 → 5 把)，第 3 箭起只提示。
#   ⇒ **不扣魔力**: 文案只把魔力写在"每次射击…召唤"上, 追加这句没提消耗。
#   ⇒ 追加时把**全部**刀刃一起重置到满时长(文案:"持续时间重置"指整组, 不是只给新的)。
# 【★ 追加刀刃的起始角 6 / 12 ★】原有三把是 0 / 8 / 16(差 120°)。24 档制下 4 把、5 把
#   都除不尽, 做不到等分 ⇒ 取 6(90°)与 12(180°), 只要和已有的不同就不会叠在同一处。
#   每刻各自 +1, 所以它们永远保持这个相位差, 视觉上是交错的多叶风车。
# ============================================================

# ⓪ 原版：有碎刀就只提示(与改造前一致), 不扣蓝、不刷新
execute if score @s zx.bb_ol matches 0 run tellraw @s [{"text":"碎刀还在场上 —— 这一发不会重复召唤","color":"gray"}]
execute if score @s zx.bb_ol matches 0 run return 0

# ① 超限：每组碎刀最多追加 2 次
scoreboard players add @s zx.bb_add 0
execute if score @s zx.bb_add matches 2.. run tellraw @s [{"text":"碎刀已满 —— 每个碎刀最多追加 2 把","color":"gray"}]
execute if score @s zx.bb_add matches 2.. run return 0
scoreboard players add @s zx.bb_add 1

# ② 基础攻击力可能已经变了(buff / 换装备) -> 重算一次, 新旧刀刃共用这一份
function fallendream:equipment/bow/bone_breaker/recalc

# ③ 自己全部刀刃：时长重置到满(10 秒 = 200 刻) + 伤害与基础值跟着刷新
$execute as @e[tag=zx.bb_blade,distance=0..,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}] run scoreboard players set @s zx.bb_life 200
$execute as @e[tag=zx.bb_blade,distance=0..,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}] run scoreboard players set @s zx.bb_ol 1
$execute as @e[tag=zx.bb_blade,distance=0..,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}] store result score @s zx.bb_dmg run data get storage zx:work bbk.dmg1000
$execute as @e[tag=zx.bb_blade,distance=0..,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}] store result score @s zx.bb_base run data get storage zx:work bbk.base1000

# ④ 追加的那一把(第 4 把角 6 / 第 5 把角 12)
data modify storage zx:work bbk.a set value 6
execute if score @s zx.bb_add matches 2 run data modify storage zx:work bbk.a set value 12
execute at @s anchored eyes positioned ^ ^ ^3.5 run function fallendream:equipment/bow/bone_breaker/blade_new with storage zx:work bbk

# ⑤ 表现
execute at @s anchored eyes positioned ^ ^ ^3.5 run particle minecraft:sweep_attack ~ ~ ~ 0.7 0.7 0.7 0.0 5 normal
execute at @s run playsound minecraft:block.grindstone.use player @a ~ ~ ~ 0.7 1.5
tellraw @s [{"text":"碎刀 +1","color":"gold"}]

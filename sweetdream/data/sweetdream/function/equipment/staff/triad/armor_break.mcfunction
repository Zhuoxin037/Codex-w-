# ============================================================
# sweetdream:equipment/staff/triad/armor_break —— 强化热刀: 累计削甲(宏展开)
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s)
# 【文案】每次攻击使目标 -1 护甲值; 命中 3 次后使其 -1 护甲韧性; 技能结束后恢复。
# 【计数】zx.tri_hit 记在目标身上, 每次命中 +1; 由 triad/second 在强化结束时清零。
# 【护甲 -N】value = -命中次数, 随累计变化 ⇒ 必须先 remove 再加(同 id 二次 add 会失败),
#   且数值要经宏展开成字面量(attribute 的数值不能是算出来的分数)。
# 【韧性 -1】恒定, 到 3 次直接写字面量 -1 即可。
# ============================================================

scoreboard players add @s zx.tri_hit 1

# ---- 记住"这份破甲是谁削的"(zx.tri_u0..u3) ----
#   恢复时(strong_end)要按 owner 比对, 否则多人同用会互相把对方的破甲恢复掉。
#   ★ 全程 `store result score @s` 直落目标 —— 不能经假玩家中转: 假玩家是全局的,
#     一刀命中多只目标时"先存假玩家再赋给 @s"会把同一个值灌给所有目标(串号)。
execute if data storage zx:work tri.u0 run execute store result score @s zx.tri_u0 run data get storage zx:work tri.u0
execute if data storage zx:work tri.u1 run execute store result score @s zx.tri_u1 run data get storage zx:work tri.u1
execute if data storage zx:work tri.u2 run execute store result score @s zx.tri_u2 run data get storage zx:work tri.u2
execute if data storage zx:work tri.u3 run execute store result score @s zx.tri_u3 run data get storage zx:work tri.u3

# ---- 护甲: -N ----
attribute @s minecraft:armor modifier remove sweetdream:tri_fire_arm
scoreboard players set #tri_na zx.meta 0
scoreboard players operation #tri_na zx.meta -= @s zx.tri_hit
execute store result storage zx:work tri.v double 1 run scoreboard players get #tri_na zx.meta
function sweetdream:equipment/staff/triad/armor_apply with storage zx:work tri

# ---- 韧性: 满 3 次才 -1(只加一次, 重复命中不会叠) ----
execute if score @s zx.tri_hit matches 3 run attribute @s minecraft:armor_toughness modifier remove sweetdream:tri_fire_tou
execute if score @s zx.tri_hit matches 3 run attribute @s minecraft:armor_toughness modifier add sweetdream:tri_fire_tou -1 add_value

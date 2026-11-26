# ============================================================
# fallendream:equipment/bow/pierce/one —— 穿孔：走廊里"接下来这一只"的结算
# ------------------------------------------------------------
# 【执行者】射手(玩家), 由 fire ④ 起手, 之后**自己递归**
# 【入参】zx:work pi {dmg4, s2b4, dmg8, s2b8}
# 【为什么逐只】超限的"命中至少 3 个后, 该箭接下来的伤害提升为 x0.08"是**顺序**
#   语义 —— 前三个 0.04、第四个起 0.08。批量投只能给同一个数值。
# 【取谁】走廊成员 zx.pi_on 里"离射手最近、且还没打过(没 zx.pi_done)"的那只。
# 【终止】每轮都给打过的打上 zx.pi_done, 候选只减不增 ⇒ 走廊清空即收。
# ============================================================

# ① 取最近的一只还没打过的
tag @e[tag=zx.pi_cur,distance=0..] remove zx.pi_cur
execute at @s run tag @e[tag=zx.pi_on,tag=!zx.pi_done,distance=0..,sort=nearest,limit=1] add zx.pi_cur
execute unless entity @e[tag=zx.pi_cur,distance=0..,limit=1] run return 0

# ② 已打到的序号(含当前这只)
scoreboard players add #pi_done zx.meta 1

# ③ 投递这一只的额外伤害(附加段 => uncapped:1b 绕过同刻受伤冷却)
data modify storage zx:work a set value {target:"@e[tag=zx.pi_cur,limit=1]",damage:0.0,type:"fallendream:skill",uncapped:1b,num:0.0,u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work pi.dmg4
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work pi.s2b4
#   超限 && 走廊里至少 3 只 && 已经轮到第 4 只之后 -> 换成 0.08
execute if score #pi_ol zx.meta matches 1 if score #pi_n zx.meta matches 3.. if score #pi_done zx.meta matches 4.. run data modify storage zx:work a.damage set from storage zx:work pi.dmg8
execute if score #pi_ol zx.meta matches 1 if score #pi_n zx.meta matches 3.. if score #pi_done zx.meta matches 4.. run data modify storage zx:work a.s2_b_num set from storage zx:work pi.s2b8
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra

# ④ 超限: 护甲值与护甲韧性 -30%, 持续 5 秒(重入时先撤旧的再挂, 见 strip)
execute if score #pi_ol zx.meta matches 1 as @e[tag=zx.pi_cur,distance=0..,limit=1] run function fallendream:equipment/bow/pierce/strip

# ⑤ 这只打完了 -> 标记, 继续下一只
tag @e[tag=zx.pi_cur,distance=0..] add zx.pi_done
execute at @s run function fallendream:equipment/bow/pierce/one

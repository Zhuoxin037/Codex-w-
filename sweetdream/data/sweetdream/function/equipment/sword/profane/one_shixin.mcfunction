# ============================================================
# sweetdream:equipment/sword/profane/one_shixin —— 带噬心：清除 + 基础攻击力 ×8（超限 +50% 独立乘区）
# ------------------------------------------------------------
# ★ 先清噬心再结算：清除会撤掉 tag_liuhuo 之外的那一条 attack_damage -20% 修饰符，
#   但本次伤害用的是 cast 阶段算好的 pf.d8（固定值），所以顺序不影响伤害本身。
# ★ 半伤打「该生物 2 格内的其他生物」，用 distance=0.1..2 把自己排除在外，
#   不再按"是否在剖线上"过滤（设计原文就是"命中的生物 2 格内的其他生物"）。
# ============================================================
function sweetdream:tag/unmark {target:"@s",mark:"shixin"}
scoreboard players add #pf_clear zx.meta 1

# ---- 主目标：×8 档 ----
data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from storage zx:work pf.d8
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work pf.u0
data modify storage zx:work a.u1 set from storage zx:work pf.u1
data modify storage zx:work a.u2 set from storage zx:work pf.u2
data modify storage zx:work a.u3 set from storage zx:work pf.u3
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @s run particle minecraft:dust{color:[0.55,0.05,0.12],scale:1.6} ~ ~1 ~ 0.5 0.6 0.5 0.03 22 normal
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.4 0.5 0.4 0.03 10 normal
execute at @s run playsound minecraft:entity.wither.hurt player @a ~ ~ ~ 0.6 0.7

# ---- 2 格内的其他生物: 未超限吃一半(= attack_mul 4 + 独立乘区 1.2) / 超限吃**相等**的伤害 ----
data modify storage zx:work a set value {target:"@e[type=!#sweetdream:no_damage,distance=0.1..2]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from storage zx:work pf.half
# 超限·剖心(2026-10-23 批 K2): "受到相等的伤害" -> 直接复用 ×8 档(含 +50% 独立乘区)
#   ★ pf.ol 是 cast ⑤ 拍下的"这一发是不是超限", 不能在这里判物品 —— 本函数执行者
#     是**被命中的生物**, `items entity @s` 看到的是它自己的装备。
execute if data storage zx:work pf{ol:1b} run data modify storage zx:work a.num set from storage zx:work pf.d8
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work pf.u0
data modify storage zx:work a.u1 set from storage zx:work pf.u1
data modify storage zx:work a.u2 set from storage zx:work pf.u2
data modify storage zx:work a.u3 set from storage zx:work pf.u3
function sweetdream:internal/damage/with_from with storage zx:work a

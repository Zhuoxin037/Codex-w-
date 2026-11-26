# ============================================================
# fallendream:equipment/axe/bind_ember/one —— 扇形单目标结算（@s = 目标）
# ------------------------------------------------------------
# 顺序很重要：**先判有没有流火（判"新获得"），再施加**。
# 反了的话人人都是"新获得"，一次扇形能白减 5 秒冷却。
# ------------------------------------------------------------
# 【原版】挂「流火」+ 缓慢Ⅱ 3 秒；原本没流火的目标计一次 #be_new。
# 【超限】文案："并使其附加「流火」、获得缓慢Ⅱ，持续 5 秒。若有附加「流火」的生物
#   则改为使其附加「夜火」并使其获得 8 秒缓慢Ⅲ。"
#   ⇒ 原本带流火的目标：摘流火、换夜火、缓慢Ⅲ 8 秒，并计一次 #be_newye（-2 秒）。
#   ★ #be_had 必须在施加**之前**拍下来 —— 这是"原本有没有"的唯一凭据。
#   ★ 换标签走 tag/unmark + tag/mark，不是 mark_consume：这是"变成"不是"被消耗"，
#     走消耗口会白触发余烬 / 回潮扣 / 烛跬那些"消耗"被动。
# ============================================================

# ① 原本带不带流火
scoreboard players set #be_had zx.meta 0
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players set #be_had zx.meta 1
execute if score #be_had zx.meta matches 0 run scoreboard players add #be_new zx.meta 1

# ② 原版：一律流火 + 缓慢Ⅱ 3 秒
execute if score #be_ol zx.meta matches 0 run function fallendream:tag/mark {target:"@s",mark:"liuhuo"}
execute if score #be_ol zx.meta matches 0 run effect give @s minecraft:slowness 3 1 true

# ③ 超限 · 原本没流火：流火 + 缓慢Ⅱ 5 秒
execute if score #be_ol zx.meta matches 1 if score #be_had zx.meta matches 0 run function fallendream:tag/mark {target:"@s",mark:"liuhuo"}
execute if score #be_ol zx.meta matches 1 if score #be_had zx.meta matches 0 run effect give @s minecraft:slowness 5 1 true

# ④ 超限 · 原本带流火：换成夜火 + 缓慢Ⅲ 8 秒
execute if score #be_ol zx.meta matches 1 if score #be_had zx.meta matches 1 run function fallendream:tag/unmark {target:"@s",mark:"liuhuo"}
execute if score #be_ol zx.meta matches 1 if score #be_had zx.meta matches 1 if entity @s[tag=!zx.status.yehuo] run scoreboard players add #be_newye zx.meta 1
execute if score #be_ol zx.meta matches 1 if score #be_had zx.meta matches 1 run function fallendream:tag/mark {target:"@s",mark:"yehuo"}
execute if score #be_ol zx.meta matches 1 if score #be_had zx.meta matches 1 run effect give @s minecraft:slowness 8 2 true

data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from storage zx:work be.dmg
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage zx:work be.s2_b_dmg
function fallendream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work be.u0
data modify storage zx:work a.u1 set from storage zx:work be.u1
data modify storage zx:work a.u2 set from storage zx:work be.u2
data modify storage zx:work a.u3 set from storage zx:work be.u3
function fallendream:internal/attack/submit_skill

execute at @s run particle minecraft:flame ~ ~1 ~ 0.35 0.4 0.35 0.01 10 normal
execute at @s run particle minecraft:lava ~ ~1 ~ 0.25 0.3 0.25 0 4 normal

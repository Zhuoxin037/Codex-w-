# ============================================================
# sweetdream:equipment/armor/borrow_fire/hit —— 借火充能后的那一次平A
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/borrow_fire_hit(player_hurt_entity + is_player_attack)
# 【文案】自身对在燃烧的生物造成伤害后则下一次普通攻击未附有「流火」的生物时
#         将使其附加「流火」，之后使其燃烧状态立即结束且使其受到相当于剩余燃烧
#         时间 × 5 的真实伤害。若其有护甲值则使其 -30% 的护甲值及 -50% 的护甲韧性，
#         之后使削减的数值加到自己身上，持续 5 秒。
# 【★ 触发条件三连 ★】① 穿着借火；② 有充能(zx.bf_rdy，由 damage/one 的
#   on_hit 打上)；③ 打中的那只**未**附有「流火」。
# 【★ 为什么充能是"下一次"而不是"持续" ★】文案写的是"下一次普通攻击" ⇒
#   打出去(或打到带流火的目标)都**不消耗**充能, 只有真正触发才清掉 ——
#   带流火的目标不是合法目标, 不该白白吃掉这一次机会。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/borrow_fire_hit
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["borrow_fire"]}] run return 0

# ① 有充能吗(没分数的人 `if score` 判不成立 ⇒ 先 add 0 建项)
scoreboard players add @s zx.bf_rdy 0
execute if score @s zx.bf_rdy matches ..0 run return 0

# ② 刚才这一下打的是哪一只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,limit=1] run return 0

# ③ 目标必须**未**附有「流火」
execute as @e[tag=zx.victim,limit=1] if entity @s[tag=zx.status.liuhuo] run return 0

# ④ 触发: 把施法者 UUID 带给 strike(受害者身上做事, 但归属要记在玩家头上)
execute store result storage zx:work bf.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work bf.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work bf.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work bf.u3 int 1 run data get entity @s UUID[3]
execute as @e[tag=zx.victim,limit=1] at @s run function sweetdream:equipment/armor/borrow_fire/strike with storage zx:work bf

# ⑤ 这一次机会用掉了
scoreboard players set @s zx.bf_rdy 0
tag @e[tag=zx.victim] remove zx.victim

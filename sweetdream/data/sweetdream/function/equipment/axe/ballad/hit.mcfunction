# ============================================================
# sweetdream:equipment/axe/ballad/hit —— 歌谣: 「下一次攻击」奏响(平A钩子)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/ballad_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文】"下一次攻击额外对自身 X 格内的 X 个生物造成一次相当于自身基础攻击力
#   ×（9-X）的真实伤害并时停 X 秒。之后清除全部「曲调」。"
# 【★ 四要素 ★】① 平A触发; ② 自身 X 格内最近的 X 个; ③ 1 次; ④ 时停 X 秒、打完清「曲调」。
# 【★ 按游戏刻去重 ★】player_hurt_entity 每命中一只触发一次 -> 一次平A算一次(zx.bd_lt)。
# 【X 取在哪一刻】取**攻击这一刻**的「曲调」层数(打完才清), 与文案"使用后…的下一次攻击"一致。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/ballad_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是歌谣
scoreboard players set #bd_ok zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["ballad"]}] run scoreboard players set #bd_ok zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["ballad"]}] run scoreboard players set #bd_ok zx.meta 1
execute unless score #bd_ok zx.meta matches 1 run return 0

# ★ 按游戏刻去重
execute if score @s zx.bd_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.bd_lt = #now manacore.meta

# 没挂状态 -> 什么都不做
execute unless score @s zx.bd_song matches 1 run return 0
scoreboard players set @s zx.bd_song 0

# X = 「曲调」层数
scoreboard players operation #bd_x zx.meta = @s zx.bd_tune
execute if score #bd_x zx.meta matches ..0 run return 0

# ① 圈目标: 自身 X 格内最近的 X 个
tag @e[tag=zx.bd_mark,distance=0..] remove zx.bd_mark
data modify storage zx:work bd.x set value 0
execute store result storage zx:work bd.x int 1 run scoreboard players get #bd_x zx.meta
execute at @s run function sweetdream:equipment/axe/ballad/pick with storage zx:work bd

# ② 真伤 = 基础攻击力 ×(9-X), 下限 ×1
scoreboard players set #bd_mul zx.meta 9
scoreboard players operation #bd_mul zx.meta -= #bd_x zx.meta
execute if score #bd_mul zx.meta matches ..0 run scoreboard players set #bd_mul zx.meta 1

data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.attack_mul double 1 run scoreboard players get #bd_mul zx.meta
function manacore:api/damage/calc

data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.bd_mark,distance=0..]"
data modify storage zx:work a.type set value "sweetdream:true_damage"
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 时停 X 秒 = X×20 tick
scoreboard players operation #bd_ts zx.meta = #bd_x zx.meta
scoreboard players operation #bd_ts zx.meta *= #20 zx.meta
data modify storage zx:work fz.target set value "@e[tag=zx.bd_mark,distance=0..]"
data modify storage zx:work fz.ticks set value 0
execute store result storage zx:work fz.ticks int 1 run scoreboard players get #bd_ts zx.meta
function sweetdream:lib/timestop with storage zx:work fz

# ④ 清除全部「曲调」+ 清标记
scoreboard players set @s zx.bd_tune 0
tag @e[tag=zx.bd_mark,distance=0..] remove zx.bd_mark

# ⑤ 表现
execute at @s run particle minecraft:note ~ ~1 ~ 1.6 0.6 1.6 0.08 40 normal
execute at @s run playsound minecraft:block.note_block.bell player @a ~ ~ ~ 1.0 1.0

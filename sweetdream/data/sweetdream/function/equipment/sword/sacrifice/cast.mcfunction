# ============================================================
# sweetdream:equipment/sword/sacrifice/cast —— 牺牲（剑·狂徒）：放血换基础攻击力
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/sacrifice（右键 consume_item）
# 【文案（用户 2026-11-01 原稿）】
#   消耗魔力 0 · 冷却 20 秒。
#   若自身当前生命值高于 30%，则自身持续流血至 20%。
#   流血期间自身基础攻击力提升相当于自身使用技能时的基础攻击力 60% 的数值。
# 【★ 流血速率：用户 2026-11-01 定「4 秒内线性流到 20%」★】
#   施放时把 (当前血量 − 最大生命值×20%) ÷ 4 存成 zx.sc_dps（毫点/秒），
#   每秒扣一次；4 秒到点或已经掉到 20% 就地收尾（两种都会撤加成）。
# 【★ 低血时不发生 ★】≤30% 不进冷却、不加成、不流血（包内惯例：
#   凝壳那种"条件不满足就整段不发生"）。
# 【★ 加成账本 zx.sc_atk ★】存"施放时基础攻击力 ×100"，撤除按同一系数取负减回。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/sacrifice

execute unless score @s zx.job matches 2 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 2 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 生命值必须高于 30%
function sweetdream:lib/hp_pct
execute if score #hp_p100 zx.meta matches ..3000 run tellraw @s {"text":"生命值不高于 30%，无法牺牲。","color":"red"}
execute if score #hp_p100 zx.meta matches ..3000 run return fail

# 只读检查（0 魔力，只看冷却）
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sacrifice",mana:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"牺牲冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# 起冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sacrifice",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 流血参数：4 秒线性流到最大生命值 20%
function sweetdream:lib/max_health_score
scoreboard players operation #sc_now zx.meta = @s zx.hp_c
scoreboard players set #sc_five zx.meta 5
scoreboard players operation #sc_floor zx.meta = #max_hp zx.meta
scoreboard players operation #sc_floor zx.meta /= #sc_five zx.meta
scoreboard players operation #sc_span zx.meta = #sc_now zx.meta
scoreboard players operation #sc_span zx.meta -= #sc_floor zx.meta
scoreboard players set #sc_four zx.meta 4
scoreboard players operation #sc_dps zx.meta = #sc_span zx.meta
scoreboard players operation #sc_dps zx.meta /= #sc_four zx.meta

scoreboard players operation @s zx.sc_dps = #sc_dps zx.meta
scoreboard players operation @s zx.sc_floor = #sc_floor zx.meta
scoreboard players operation @s zx.sc_until = #now manacore.meta
scoreboard players add @s zx.sc_until 80
scoreboard players set @s zx.sc_on 1

# 加成：施放时的基础攻击力 ×0.6（账本记 ×100）
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set @s zx.sc_atk 0
execute store result score @s zx.sc_atk run data get storage manacore:out r.value 100
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.006 run scoreboard players get @s zx.sc_atk
function manacore:api/stats/add

# 表现
execute at @s run particle minecraft:dust{color:[0.55,0.05,0.08],scale:1.2} ~ ~1 ~ 0.6 0.9 0.6 0.03 30 normal
execute at @s run playsound minecraft:entity.player.hurt player @a ~ ~ ~ 0.9 0.7

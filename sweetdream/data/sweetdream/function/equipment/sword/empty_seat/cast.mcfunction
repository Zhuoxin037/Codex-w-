# ============================================================
# sweetdream:equipment/sword/empty_seat/cast —— 虚位（钻剑 · 主动技能）
# ------------------------------------------------------------
# 【技能原文】
#   魔力 220 · 冷却 35 秒
#   "使用后清空自身全部术阵位，对前方 3 格内的全部生物造成（6 × 清空的术阵位数）点
#    固定伤害，并使其获得 5 秒虚弱Ⅱ。"
# 【四要素】
#   ① 触发：右键。
#   ② 范围：前方 3 格 ⇒ 3 个采样点（1.0/2.0/3.0），判定半径 1.5。
#   ③ 次数：立即 1 次。
#   ④ 时长：无持续；虚弱Ⅱ 5 秒。
# 【固定伤害】绕开 api/damage/calc（口径 14）：a.num ← 6×占位数 直接投递，
#   叠多少减伤、身上有多少增益都不影响这一段。
# 【★ 清空只清自己名下的 ★】formation/clear 按 uuid 清（manacore 接口自带归属过滤），
#   不会动队友的术阵。★ 这也是本件"和所有布阵装备互相排斥"的实现基础 ——
#   阵位占满时清空数最大，空着时被动最大。
# 【顺序】先读占用数 → 造成伤害 → 再清空。反了的话读完就是 0。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/empty_seat

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["empty_seat"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["empty_seat"]}] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查：冷却 + 魔力 220
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:empty_seat",mana:220.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"虚位冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 220）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 220
data modify storage manacore:in arg set value {uuid:"",value:220.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 220）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 35 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:empty_seat",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 读当前占用数（= 将被清空的阵位数）
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
scoreboard players set #es_n zx.meta 0
execute store result score #es_n zx.meta run data get storage manacore:out r.count
execute if score #es_n zx.meta matches ..0 run scoreboard players set #es_n zx.meta 0

# 伤害 = 6 × 占位数（×3 再 ×2，#6 没有单独常数）
scoreboard players set #es_d zx.meta 0
scoreboard players operation #es_d zx.meta = #es_n zx.meta
scoreboard players operation #es_d zx.meta *= #3 zx.meta
scoreboard players operation #es_d zx.meta *= #2 zx.meta

# 拍施法者 UUID（dmg 在目标上下文跑，拿不到玩家）
data modify storage zx:work es.u0 set from entity @s UUID[0]
data modify storage zx:work es.u1 set from entity @s UUID[1]
data modify storage zx:work es.u2 set from entity @s UUID[2]
data modify storage zx:work es.u3 set from entity @s UUID[3]

# ⑥ 收集前方 3 格内的生物
tag @e[tag=zx.es_hit] remove zx.es_hit
execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/sword/empty_seat/probe
execute rotated ~ 0 positioned ^ ^ ^2.0 run function sweetdream:equipment/sword/empty_seat/probe
execute rotated ~ 0 positioned ^ ^ ^3.0 run function sweetdream:equipment/sword/empty_seat/probe

# ⑦ 结算（固定伤害 + 虚弱Ⅱ），然后清空自己名下的术阵位
execute if score #es_n zx.meta matches 1.. as @e[tag=zx.es_hit,distance=..12] at @s run function sweetdream:equipment/sword/empty_seat/dmg
execute if score #es_n zx.meta matches 1.. run data modify storage manacore:in arg set value {uuid:""}
execute if score #es_n zx.meta matches 1.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #es_n zx.meta matches 1.. run function manacore:api/formation/clear

tag @e[tag=zx.es_hit] remove zx.es_hit

# ⑧ 表现
execute if score #es_n zx.meta matches 1.. run playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.9 1.2
execute if score #es_n zx.meta matches 1.. run particle minecraft:enchant ~ ~1 ~ 2.0 0.8 2.0 0.4 30 normal

# ============================================================
# sweetdream:equipment/staff/long_night/skill —— 长夜: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【技能原文(必须和这里对上)】
#   魔力 400 / 冷却 80 秒。
#   "使用后召唤一个术阵，并在自身位置生成半径 6 格的"夜原"，持续 8 秒。"
#   ✦ 夜原: "每秒消耗其中一个生物的「夜火」并使其附加「流火」，且其护甲值及护甲韧性
#    -60%。之后对其造成一次相当于自身最大魔力值 ×0.12 的伤害。每消耗一次，则"夜原"
#    的后续伤害提高 8%（独立乘区）。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 潜行 + 右键(见 cast 的分派)。
#   ② 目标范围: 自身位置半径 6 格 -> field_tick 的 distance=..6;
#      "其中一个生物" = **随机 1 个**带「夜火」的(2026-10-16 用户拍板口径)。
#   ③ 次数: 每秒 1 次, 共 8 次。
#   ④ 时长: 8 秒(marker 上 zx.ln_ft=8, lib/second 每秒 -1, 归零收场)。
# 【★ 术阵: 两手都要(RULES"文案说术阵时") ★】
#   ① 框架登记 formation/create(id 固定 -> 重开只刷新不越堆), ② marker 存位置
#     (框架**不存位置**, 半径 6 的判定必须有圆心)。
#   术阵持续 = 8 秒(和夜原同寿) —— ★ 不能写 0.0: 那是"永久术阵"(坑 46), 会白占槽位。
# 【伤害口径】夜原每秒那一段 = 最大魔力值 ×0.12(逐秒 calc, 因为要乘独立的 1.08^n)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(与同批法杖一致; 本件暂无超限石, mod 会直接返回)
function sweetdream:overlimit/api/snap

# ② 只读检查: 冷却 + 魔力 400
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:long_night",mana:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #ln_need zx.meta 0
execute store result score #ln_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"长夜冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ln_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 400(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:400.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ln_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 80 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:long_night",cooldown_seconds:80.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑤ 框架登记一个真术阵(整个玩家只有一个 id -> 重开只刷新)
#    ★ 不看返回值: 上限满(formation_limit)不影响技能, 夜原照样生成(与威霆同一口径)。
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:long_night",type:"nightyard",duration_seconds:8.0,data:{radius:6.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 在自身位置生成「夜原」(见 field_one)
data modify storage zx:work lnf.uu set from storage zx:data self.uuid
data modify storage zx:work lnf.u0 set from entity @s UUID[0]
data modify storage zx:work lnf.u1 set from entity @s UUID[1]
data modify storage zx:work lnf.u2 set from entity @s UUID[2]
data modify storage zx:work lnf.u3 set from entity @s UUID[3]
execute at @s run function sweetdream:equipment/staff/long_night/field_one with storage zx:work lnf

# ⑦ 表现: 夜色压下
execute at @s run playsound minecraft:entity.evoker.cast_spell player @a ~ ~ ~ 1.0 0.6
execute at @s run particle minecraft:reverse_portal ~ ~0.6 ~ 4.0 0.6 4.0 0.08 90 normal
execute at @s run particle minecraft:soul_fire_flame ~ ~0.5 ~ 4.4 0.4 4.4 0.02 40 normal
tellraw @s [{"text":"长夜：夜原降临","color":"dark_purple"}]

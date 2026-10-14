# ============================================================
# sweetdream:equipment/axe/anion/cast —— 负离子: 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/anion 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 40 魔力 / 冷却 30 秒。使用后对自身 6 格内的随机 3 个生物
#   释放闪电，并对其造成相当于自身当前魔力值 ×0.1 的伤害。
#
# 【★ 超限·负离子 加在这把上的机制(逐字照抄 oldef."anion".lore)★】
#   "使用后对自身 6 格内的**全部**生物释放闪电并对其造成相当于自身当前魔力值
#    ×0.12 的伤害，1 秒后再释放闪电并对其相当于自身**最大**魔力值 ×0.08 的伤害。
#    之后 8 秒内自身召唤闪电时闪电额外对落地处造成相当于自身当前魔力值 ×0.1 的伤害"
#   落实: ①目标 随机3 -> 全部(⑥); ②倍率 0.1 -> 0.12(⑧);
#         ③1 秒后的第二道雷(走 zx.an_2nd + core/tick, 见 second_strike);
#         ④8 秒"雷劲"窗口(zx.an_boost=8, 见 lib/on_lightning 与 ol_bonus)。
#   ★ 注意原文这两处的口径**不同**: 第一下是"当前魔力", 1 秒后那下是"最大魔力"。
#
# 【伤害口径 = other_mul(当前魔力)】框架的 other_mul 基数**默认就是当前魔力**
#   (见 manacore/internal/damage/use_other) —— 所以只写 {other_mul:0.1} 即可。
#   ★ 别写成 max_mana_mul(那是"最大魔力"), 文案写的是**当前**魔力。
#   ★ 登记口径表时也要标 oth:1b(见 lib/skill_mul/def 的 wchan.anion)。
#
# 【为什么先打标签、再由玩家身份统一结算】
#   /damage 要"by <施法者>"才把击杀记在玩家头上, 而选择器只能逐个 `as` 展开
#   —— 若在"目标"的身份下调 api/damage, @s 就不是玩家了, 归属丢。
#   所以照 sea_hurt_go 的定式:
#     ① 先给随机 3 只打临时标签 zx.an_hit(此时 @s 还是玩家)
#     ② 闪电逐个 `at 目标` 放(纯表现)
#     ③ 伤害由玩家身份发起, target 用范围选择器
#     ④ 用完立刻清掉临时标签
#   (这是本包"范围技能统一结算"的标准写法, 新写的 AoE 技能照抄这一段。)
#
# 【没有目标就不放】照沉渊 cast ③ 的先例: 6 格内一只可打的都没有 →
#   不扣蓝、不进冷却(只提示一行)。避免"空放"白吃 40 魔力。
#
# 【闪电用的是**原版真闪电**】和 超•负•荷(charge/bolt) / 雷鸣(thunder) 一致:
#   落点 3 格内实体各吃 5 点伤害 + 着火 —— 所以目标离你太近时你自己也会被劈到。
#   ⚠️ 若实测太痛, 把 ⑦ 换成"电火花粒子 + 雷声"(不带 summon lightning_bolt) 即可,
#      伤害不受影响(伤害一直走 ⑧ 我们自己的公式)。
# ============================================================

# ⓪ 撤销自己的进度(不撤销的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/axe/anion

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①' 超限快照: 手里这把是不是超限版(判一次存到玩家身上)
#   ★ 为什么拍快照: 后面的 ⑨ 伤害、⑩ 的 8 秒窗口都发生在这一刻之后,
#     而"手里那把"到那时可能已经不准了(见 RULES 的"施法快照")。
function sweetdream:equipment/axe/anion/is_ol
scoreboard players operation @s zx.an_ol = #an_ol zx.meta

# ② 只读检查: 冷却 + 魔力 40
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:anion",mana:40.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"负离子冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 40)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 没有就整个不放(不扣蓝、不进冷却)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run return fail

# ④ 扣魔力 40
data modify storage manacore:in arg set value {uuid:"",value:40.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 40)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:anion",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 圈目标: 基础版 = 6 格内随机 3 只; 超限版 = 6 格内**全部**
#   ★ sort=random 每次求值都会重挑 ⇒ 必须**先冻结成标签**, 否则后面每用一次
#     这个选择器就换一批人(闪电打 A, 伤害却落到 B 身上)。
tag @e[tag=zx.an_hit] remove zx.an_hit
execute if score @s zx.an_ol matches 0 at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..6,sort=random,limit=3] add zx.an_hit
execute if score @s zx.an_ol matches 1 at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..6] add zx.an_hit

# ⑦ 闪电(逐个 at 目标放; 原版真闪电, 见头注释的注意事项)
#   ★ 必须带 zx.th_seen ★ 否则会被 tool/thunder/strike 的每刻扫描当"新雷"接管,
#     给 6 格内每个持雷鸣的玩家追加一道连锁雷(2026-10-08 修)。
#   ★ 紧接着那一行 = "自身召唤闪电"的公共收尾钩子(超限 8 秒雷劲挂在这儿)。
execute at @e[tag=zx.an_hit,distance=0..] run summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_own"]}
execute at @e[tag=zx.an_hit,distance=0..] run function sweetdream:lib/on_lightning

# ⑧ 伤害: 基础版 当前魔力 ×0.1; 超限版 当前魔力 ×0.12(执行者仍是玩家 -> 归属正确)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.an_ol matches 1 run data modify storage manacore:in arg.other_mul set value 0.12
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.an_hit,distance=0..]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ⑨ 清临时标签(不管有没有打到都要清)
tag @e[tag=zx.an_hit,distance=0..] remove zx.an_hit

# ⑩ 超限: 之后 8 秒的"雷劲"窗口 + 1 秒后的第二道雷(最大魔力 ×0.08)
#   ①zx.an_boost = 还剩几秒的雷劲(lib/on_lightning 判它, lib/second 每秒 -1);
#   ②zx.an_2nd  = 还有几刻放"1 秒后那道雷"(core/tick 每刻推, 见 second_strike)。
execute if score @s zx.an_ol matches 1 run scoreboard players set @s zx.an_boost 8
execute if score @s zx.an_ol matches 1 run scoreboard players set @s zx.an_2nd 20
execute if score @s zx.an_ol matches 1 run tellraw @s [{"text":"超限·负离子 · 8 秒内自身闪电附带落点伤害","color":"light_purple"}]
execute if score @s zx.an_ol matches 1 run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.6 1.4
scoreboard players set @s zx.an_ol 0

# ⑪ 表现
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 1.2 0.8 1.2 0.08 40 normal
execute at @s run playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.8 1.2

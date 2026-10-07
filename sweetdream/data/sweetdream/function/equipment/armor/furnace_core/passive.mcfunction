# ============================================================
# sweetdream:equipment/armor/furnace_core/passive —— 炉心的被动(每秒跑一次)
# ------------------------------------------------------------
# 【文案】
#   ① 自身魔力值上限 +100，最大生命值 +10，基础攻击力 +5。
#   ② 自身每攻击一次处于燃烧状态的生物则积攒一层「燃灰」（最大为 10 层）。
#   ③ 每有一层「燃灰」则自身魔力值上限 +30，基础攻击力 +X（X 为自身当前
#      基础攻击力 ×0.1，最低为 3），最大生命值 +Y（Y 为自身当前最大生命值
#      ×0.1，最低为 5），且每秒恢复 1 点魔力值。
#   ④「燃灰」每 3 秒 -1 层。
#
# 【★ X / Y 的口径(本实现的取舍, 写在这里免得以后看不懂) ★】
#   字面是"自身**当前**基础攻击力 ×0.1", 但"当前"如果包含炉心自己加的那部分,
#   就会变成自我引用: 层数越高 -> 当前攻击力越高 -> 下一层给的越多 -> 每秒重算
#   还会指数放大。所以这里取的是**不含炉心加成的**那个基数
#   (面板读数 - 自己的账本 zx.fc_atk / zx.fc_hp), 于是 X / Y 稳定可预期:
#       攻击力 45 的人, X 恒为 4(45 ×0.1 取整), 10 层就是 +40。
#   想改成"含加成"的读法, 把下面 ⑤⑥ 里减账本那两行删掉即可(但会失控)。
# 【③ 里的"每秒恢复 1 点"按"每层 1 点"实现】整句都在"每有一层"的管辖下,
#   所以 10 层 = 每秒 10 点。若想改成"只要有燃灰就 1 点", 把 ⑦ 换成加常数 1。
# 【为什么对全部玩家跑】三条都是"穿上加、脱下减"的差值账本 —— 只筛穿胸甲的人
#   的话, 脱下那一秒没人执行, 加成永远减不回去。所以进来先自己判穿着。
# ============================================================

# ① 拿 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己穿了吗(炉心是下界合金胸甲, 槽位 armor.chest)
scoreboard players set #on zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["furnace_core"]}] run scoreboard players set #on zx.meta 1

# ③ 燃灰衰减: 每 3 秒 -1 层。没穿(或没层)时把计时清零 —— 不清的话
#   脱下再穿上会立刻吃掉一层。
execute if score #on zx.meta matches 1 if score @s zx.fc_ash matches 1.. run scoreboard players add @s zx.fc_t 1
execute if score #on zx.meta matches 1 unless score @s zx.fc_ash matches 1.. run scoreboard players set @s zx.fc_t 0
execute unless score #on zx.meta matches 1 run scoreboard players set @s zx.fc_t 0
execute if score @s zx.fc_t matches 3.. run scoreboard players remove @s zx.fc_ash 1
execute if score @s zx.fc_t matches 3.. run scoreboard players set @s zx.fc_t 0

# ④ 参与计算的层数: 脱下就当 0 层(加成要跟着归零, 层数本身留着不删 ——
#    再穿上时按剩下的层数继续, 而不是从头攒)
scoreboard players set #ash zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players operation #ash zx.meta = @s zx.fc_ash

# ⑤ 魔力上限: 100 + 30 × 层数
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 100
scoreboard players operation #tmp zx.meta = #ash zx.meta
scoreboard players operation #tmp zx.meta *= #30 zx.meta
scoreboard players operation #want zx.meta += #tmp zx.meta
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.fc_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/furnace_core/apply_mana

# ⑥ X = (面板攻击力 - 本装备已加的) × 0.1, 最低 3; 总加成 = 5 + X × 层数
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
#   ⚠️ "先归零再 store": data get 读不到时 store 不执行, 会留着上一次的值。
scoreboard players set #base zx.meta 0
execute store result score #base zx.meta run data get storage manacore:out r.value 100
#   ⚠️ 账本 zx.fc_atk 记的是"已加了多少攻击力"(原量纲), 而 #base 是 atk×100 ——
#   必须把账本也 ×100 才能相减, 否则会以 100 倍的误差把基数算成负数。
scoreboard players operation #base2 zx.meta = @s zx.fc_atk
scoreboard players operation #base2 zx.meta *= #100 zx.meta
scoreboard players operation #base zx.meta -= #base2 zx.meta
scoreboard players operation #x zx.meta = #base zx.meta
scoreboard players operation #x zx.meta /= #10 zx.meta
scoreboard players operation #x zx.meta /= #100 zx.meta
execute if score #x zx.meta matches ..2 run scoreboard players set #x zx.meta 3
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 5
scoreboard players operation #tmp zx.meta = #x zx.meta
scoreboard players operation #tmp zx.meta *= #ash zx.meta
scoreboard players operation #want zx.meta += #tmp zx.meta
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.fc_atk
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/furnace_core/apply_atk

# ⑦ Y = (面板最大生命 - 本装备已加的) × 0.1, 最低 5; 总加成 = 10 + Y × 层数
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #hp zx.meta 0
execute store result score #hp zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #hp2 zx.meta = @s zx.fc_hp
scoreboard players operation #hp2 zx.meta *= #100 zx.meta
scoreboard players operation #hp zx.meta -= #hp2 zx.meta
scoreboard players operation #y zx.meta = #hp zx.meta
scoreboard players operation #y zx.meta /= #10 zx.meta
scoreboard players operation #y zx.meta /= #100 zx.meta
execute if score #y zx.meta matches ..4 run scoreboard players set #y zx.meta 5
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 10
scoreboard players operation #tmp zx.meta = #y zx.meta
scoreboard players operation #tmp zx.meta *= #ash zx.meta
scoreboard players operation #want zx.meta += #tmp zx.meta
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.fc_hp
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/furnace_core/apply_hp

# ⑧ 回魔: 每层每秒 1 点。走 regen_extra 公共账本(debug 的"回魔/秒"那一行
#    读它, 见 lib/reg/build 的 gsent 说明), 不用自己另开一套。
execute if score #ash zx.meta matches 1.. run scoreboard players operation @s zx.regen_extra += #ash zx.meta
execute if score #ash zx.meta matches 1.. run function sweetdream:equipment/armor/furnace_core/regen

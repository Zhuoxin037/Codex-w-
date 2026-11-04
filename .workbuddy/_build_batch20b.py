# -*- coding: utf-8 -*-
"""批 20-B1：胜利誓约之剑 + 枢 + 承 的机制文件 + 进度"""
import os
ROOT = r'D:/数据包/sweetdream/data/sweetdream'
FN = os.path.join(ROOT, 'function')
AD = os.path.join(ROOT, 'advancement')

F = {}

# ============================================================
# 胜利誓约之剑
# ============================================================
F['equipment/sword/oath_victory/hit.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/sword/oath_victory/hit —— 胜利誓约 · 被动（20% 给 5 点临时生命）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/oath_victory_hit（player_hurt_entity，只算平A）
# 【执行者】动手的玩家
# 【文案】"每次普攻命中生物后，有 20% 的概率使自身获得 5 点临时生命值。"
# 【★ 四要素 ★】① 触发=普攻命中（一次平A一次）② 概率 20% = %5 ③ 次数 1 ④ 时长：临时
#   生命按 lib/thp 的 60 秒上限走（文案没写时长，包内统一口径见 lib/thp/set）。
# 【★ 同刻去重 ★】player_hurt_entity **每命中一只就抛一次**（横扫打 3 只 = 同刻 3 遍）
#   ⇒ 用 zx.ov_lt 记"本刻已结算"。没分数的玩家 `if score = #now` 判失败 ⇒ 第一次放行。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/oath_victory_hit
# 满蓄力闸（全包统一口径，见 lib/atk_charge 头部）
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控：主手或副手是胜利誓约
scoreboard players set #ov_ok zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["oath_victory"]}] run scoreboard players set #ov_ok zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["oath_victory"]}] run scoreboard players set #ov_ok zx.meta 1
execute unless score #ov_ok zx.meta matches 1 run return 0

# 每次攻击去重
execute if score @s zx.ov_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.ov_lt = #now manacore.meta

# 20%（掷骰一定要掷，保持序列连续）
function sweetdream:lib/rnd
scoreboard players operation #ov_r zx.meta = #rnd zx.meta
scoreboard players set #ov_5 zx.meta 5
scoreboard players operation #ov_r zx.meta %= #ov_5 zx.meta
execute unless score #ov_r zx.meta matches 0 run return 0

# +5 点临时生命（上限 = 最大生命 ×2，由 lib/thp/add 夹）
scoreboard players set #thp_v zx.meta 5
function sweetdream:lib/thp/add

# 表现
particle minecraft:end_rod ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
'''

F['equipment/sword/oath_victory/cast.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/sword/oath_victory/cast —— 胜利誓约 · 主动（右键）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/oath_victory（consume_item）
# 【文案】魔力 200 / 冷却 10 秒。突击到自身 5 格内的生物后方并造成 基础攻击力 ×5 的伤害；
#   之后在停留处展开半径 3、持续 6 秒的领域，自身在领域内每秒恢复 3 点生命并获得
#   20% 最大生命的临时生命。
# 【★ 突击怎么写 ★】`execute at <目标> rotated as <目标> run tp @s ^ ^ ^-1.5`
#   · `at` 只换坐标基点（不换执行者）、`rotated as` 只换朝向 ⇒ `^ ^ ^-1.5` 的原点落在
#     目标身上、`-` 方向就是目标背后 1.5 格。
#   · 目标卡在墙里时 tp 可能失败（原版会夹到合法位置），不额外处理：最坏是留在原地，
#     伤害与领域照常结算。
# 【★ 顺序 ★】先扣蓝 → 记冷却 → 位移 → 打伤害 → 放领域（领域在"停留处"= 位移之后）。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/oath_victory

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 只读检查：冷却 + 魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:oath_victory",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"胜利誓约冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# 5 格内没有生物就不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..5] run tellraw @s [{"text":"5 格内没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..5] run return fail

# 扣魔力 200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# 记冷却 10 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:oath_victory",cooldown_seconds:10.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 选最近的一个目标（钉成 zx.ov_t，避免后面每步重挑）
tag @e[tag=zx.ov_t] remove zx.ov_t
execute as @e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=1] run tag @s add zx.ov_t

# 突击到其后方（见文件头）
execute at @e[tag=zx.ov_t,limit=1] rotated as @e[tag=zx.ov_t,limit=1] run tp @s ^ ^ ^-1.5

# 伤害：基础攻击力 ×5（把 5 倍算进伤害投递，乘区照常吃）
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.ov_t,distance=..3]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# 领域：停留在处（位移之后）
data modify storage zx:work ovf.uuid set from storage zx:data self.uuid
execute store result storage zx:work ovf.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work ovf.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work ovf.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work ovf.u3 int 1 run data get entity @s UUID[3]
execute at @s run function sweetdream:equipment/sword/oath_victory/field with storage zx:work ovf

# 表现
particle minecraft:sweep_attack ~ ~1 ~ 0.6 0.2 0.6 0.05 12 normal
playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.4 1.4

tag @e[tag=zx.ov_t] remove zx.ov_t
'''

F['equipment/sword/oath_victory/field.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/sword/oath_victory/field —— 生成领域 marker（宏 {uuid,u0..u3}）
# ------------------------------------------------------------
# 【执行位置】施法者停留处（cast 里 `at @s` 送进来）
# 【领域是什么】marker，NBT 存施法者 UUID（uu 文本 + u 四个整数）。
#   · u 四个整数给 lib/u_by 反查玩家（零 NBT，卡顿坑 1）；
#   · uu 文本只用于排查，不参与判定。
# 【计时】zx.ov_ft = 6 秒，lib/second 每秒 -1，归零 kill。
# 【代码】"半径 3" 不在 NBT 里 —— 判定写在 field_tick 的选择器上，改半径只需改那一处。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.ov_field","zx.ov_new"],data:{zx:{uu:"$(uuid)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

execute as @e[tag=zx.ov_new,distance=..2,limit=1] run scoreboard players set @s zx.ov_ft 6
tag @e[tag=zx.ov_new,distance=..2] remove zx.ov_new
'''

F['equipment/sword/oath_victory/field_tick.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/sword/oath_victory/field_tick —— 领域每秒一跳（执行者 = marker）
# ------------------------------------------------------------
# 【谁调用它】lib/second（三个维度各扫一遍 zx.ov_field）
# 【每秒】① 按 marker 里存的 UUID 反查施法者 ② 施法者在 3 格内 ⇒ field_heal
#   ③ 计时 -1，归零 kill。
# 【★ 为什么"反查"而不是"给玩家挂计时" ★】领域在地上，施法者走开就不该再吃回复。
#   把状态挂在玩家身上等于假设"人一直在圈里"，那是错的（神裁/凝壳同款口径）。
# ============================================================

data modify storage zx:work ub.u0 set from entity @s data.zx.u[0]
data modify storage zx:work ub.u1 set from entity @s data.zx.u[1]
data modify storage zx:work ub.u2 set from entity @s data.zx.u[2]
data modify storage zx:work ub.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/u_by

# 施法者本人站在圈里才给（radius 3，改这里就改领域半径）
execute as @a[tag=zx.ub,distance=..3,limit=1] at @s run function sweetdream:equipment/sword/oath_victory/field_heal

# 表现：领域里一圈缓缓上升的光
particle minecraft:end_rod ~ ~0.2 ~ 1.6 0.15 1.6 0.01 6 normal

scoreboard players remove @s zx.ov_ft 1
execute if score @s zx.ov_ft matches ..0 run kill @s
'''

F['equipment/sword/oath_victory/field_heal.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/sword/oath_victory/field_heal —— 领域内的每秒回复（执行者=玩家）
# ------------------------------------------------------------
# 【文案】"自身在领域内时每秒恢复 3 点生命值并获得相当于自身最大生命值 ×0.2 的临时生命值"
# 【★ 顺序 ★】先 lib/heal（3 点精确治疗），再算 20% 最大生命给临时生命。
#   lib/heal 会临时压 max_health（heal_cap），lib/max_health_score 已把它排除 ⇒ 两者
#   谁先谁后都不影响"最大生命"的读数，但先治疗后加临时生命更符合文案语序。
# ============================================================

scoreboard players set #heal_pt zx.meta 3
function sweetdream:lib/heal

# 临时生命 = 最大生命 ×0.2
#   ★ 单位链（别写错，错一步就差 1000 倍）★ #max_hp 是**毫点**（×1000），
#   #thp_v 要的是**整点** ⇒ 先把毫点降成点（÷1000），再 ×20÷100 取两成。
#   即 20 点血 → 20×20÷100 = 4 点。曾经写成 ÷10×2（= 毫点的 20%）⇒ 给 4000 点。
function sweetdream:lib/max_health_score
scoreboard players set #thp_v zx.meta 0
scoreboard players operation #thp_v zx.meta = #max_hp zx.meta
scoreboard players operation #thp_v zx.meta /= #1000 zx.meta
scoreboard players operation #thp_v zx.meta *= #20 zx.meta
scoreboard players operation #thp_v zx.meta /= #100 zx.meta
function sweetdream:lib/thp/add
'''

# ============================================================
# 枢
# ============================================================
F['equipment/armor/pivot/second.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/pivot/second —— 「枢」术阵位上限 +1（每秒对账）
# ------------------------------------------------------------
# 【执行者】玩家（lib/second 用 as @a 送进来）
# 【文案】自身魔力值上限 +120（在 armor_mana/passive 统一登记）。自身术阵位上限 +1。
# 【★ 为什么改 stats.formation_limit ★】前置包 formation/create 就是按它判满没满
#   （见 manacore internal/formation/create.mcfunction）⇒ 这是唯一正确的入口。
#   **不要**直接改 formations 数组（那是占用，不是上限）。
# 【★ 差值账本 zx.pv_lim ★】0 = 没加 / 1 = 已加 1。重登后玩家记录还在，靠它避免重复叠加。
# ============================================================

execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run function sweetdream:equipment/armor/pivot/off
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run return 0

execute if score @s zx.pv_lim matches 1 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"formation_limit",value:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/add
scoreboard players set @s zx.pv_lim 1
'''

F['equipment/armor/pivot/off.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/pivot/off —— 摘下「枢」时把术阵位上限还回去
# ------------------------------------------------------------
# 【执行者】玩家（pivot/second 在判定"没穿"时调用）
# 【★ 必须先判账本 ★】没加过就减，会把上限变成 2（甚至负数）—— 而且不会报错。
# ============================================================

execute unless score @s zx.pv_lim matches 1 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"formation_limit",value:-1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/add
scoreboard players set @s zx.pv_lim 0
'''

# ============================================================
# 承
# ============================================================
F['equipment/armor/bearing/second.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/bearing/second —— 「承」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家（lib/fm/read 之后）
# 【文案】魔力 +140（armor_mana 登记）；每占用 1 个术阵位 → 护甲 +2 / 韧性 +1（最多 3 层）；
#   术阵为空时移速 +6%。
#   套装（枢 + 承）：术阵位全满 → 8 秒「阵成」（技能伤害 +15% 独立乘区、技能冷却 −10%）；
#   术阵自然结束或主动归还时返还 25 点魔力值；每 12 秒最多进入一次。
# 【★ 层数怎么来 ★】zx.fm_u（lib/fm/read 每秒下发），n = min(fm_u, 3)。
# 【★ 换档必须先摘后挂 ★】同 id modifier 重复 add 会失败，且失败会**截断**后续命令
#   （attribute 的 remove 不存在虽不截断，但 add 重复一定失败）⇒ 用账本 zx.br_a / zx.br_t
#   记"当前挂的是几"，档位没变就一条 attribute 都不发。
# 【★ 「阵成」的触发是"边沿"不是"电平" ★】zx.br_full 记上一秒是否满，只有 0→1 才触发。
# 【★ 「返还 25 魔力」为什么用"占用下降"判 ★】前置包的 formation_remove 事件带的是
#   **uuid 文本**，反查玩家要序列化 NBT（卡顿坑 1）；而占用数本来每秒就在读 ⇒
#   直接看 zx.fm_u 掉了几个，掉 N 个返还 25×N。"自然结束/主动归还"都表现为占用下降。
# ============================================================

# ⓪ 没穿 → 全部撤掉
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"]}] run function sweetdream:equipment/armor/bearing/off
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"]}] run return 0

# ① 层数 n = min(fm_u, 3)
scoreboard players set #br_n zx.meta 0
scoreboard players operation #br_n zx.meta = @s zx.fm_u
scoreboard players set #br_3 zx.meta 3
execute if score #br_n zx.meta > #br_3 zx.meta run scoreboard players set #br_n zx.meta 3
execute if score #br_n zx.meta matches ..0 run scoreboard players set #br_n zx.meta 0

# ② 护甲 = 2n
scoreboard players set #br_a zx.meta 0
scoreboard players operation #br_a zx.meta = #br_n zx.meta
scoreboard players set #br_2 zx.meta 2
scoreboard players operation #br_a zx.meta *= #br_2 zx.meta

# ③ 换档（护甲）
execute unless score #br_a zx.meta = @s zx.br_a run function sweetdream:equipment/armor/bearing/attr_arm
# ④ 换档（韧性 = n，整数点）
execute unless score #br_n zx.meta = @s zx.br_t run function sweetdream:equipment/armor/bearing/attr_tou

# ⑤ 套装：返还魔力 + 「阵成」（放在移速换档**之前** —— 下面那段会 return）
function sweetdream:equipment/armor/bearing/refund
function sweetdream:equipment/armor/bearing/set_full

# ⑥ 术阵为空 → 移速 +6%
scoreboard players set #br_s zx.meta 0
execute if score @s zx.fm_u matches 0 run scoreboard players set #br_s zx.meta 1
execute if score #br_s zx.meta = @s zx.br_spd run return 0
execute if score @s zx.br_spd matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:br_spd
scoreboard players set @s zx.br_spd 0
execute if score #br_s zx.meta matches 1 run attribute @s minecraft:movement_speed modifier add sweetdream:br_spd 0.06 add_multiplied_total
scoreboard players operation @s zx.br_spd = #br_s zx.meta
'''

F['equipment/armor/bearing/attr_arm.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/bearing/attr_arm —— 换"护甲值"档（#br_a = 目标值）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】modifier 的数值只能是字面量 ⇒ 0/2/4/6 四档各写一条。
#   层数上限 3（最多 +6 护甲），改成别的上限时这四个分支必须一起改。
# ============================================================

execute if score @s zx.br_a matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:br_arm
scoreboard players set @s zx.br_a 0
execute if score #br_a zx.meta matches 2 run attribute @s minecraft:armor modifier add sweetdream:br_arm 2 add_value
execute if score #br_a zx.meta matches 4 run attribute @s minecraft:armor modifier add sweetdream:br_arm 4 add_value
execute if score #br_a zx.meta matches 6 run attribute @s minecraft:armor modifier add sweetdream:br_arm 6 add_value
scoreboard players operation @s zx.br_a = #br_a zx.meta
'''

F['equipment/armor/bearing/attr_tou.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/bearing/attr_tou —— 换"护甲韧性"档（#br_n = 层数）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】0/1/2/3 三档（0 层不挂）各写一条。
# ============================================================

execute if score @s zx.br_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove sweetdream:br_tou
scoreboard players set @s zx.br_t 0
execute if score #br_n zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier add sweetdream:br_tou 1 add_value
execute if score #br_n zx.meta matches 2 run attribute @s minecraft:armor_toughness modifier add sweetdream:br_tou 2 add_value
execute if score #br_n zx.meta matches 3 run attribute @s minecraft:armor_toughness modifier add sweetdream:br_tou 3 add_value
scoreboard players operation @s zx.br_t = #br_n zx.meta
'''

F['equipment/armor/bearing/off.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/bearing/off —— 摘下「承」：撤属性 + 清套装状态
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 只撤自己挂过的 ★】三个账本为 0 就一条 attribute 都不发（remove 不存在的会失败）。
#   套装状态（阵成/满档记录）也一起清 —— 否则摘了腿还留着 8 秒增伤。
# ============================================================

execute if score @s zx.br_a matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:br_arm
execute if score @s zx.br_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove sweetdream:br_tou
execute if score @s zx.br_spd matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:br_spd

scoreboard players set @s zx.br_a 0
scoreboard players set @s zx.br_t 0
scoreboard players set @s zx.br_spd 0
scoreboard players set @s zx.br_full 0
scoreboard players set @s zx.br_zc 0
'''

F['equipment/armor/bearing/set_full.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/bearing/set_full —— 套装：「阵成」的进入与计时（每秒）
# ------------------------------------------------------------
# 【执行者】玩家（已确认穿着「承」；套装还要求同时穿着「枢」）
# 【文案】术阵位全满时获得 8 秒「阵成」：技能伤害 +15%（独立乘区），技能冷却 −10%。
#   每 12 秒最多进入一次「阵成」。
# 【★ 边沿触发 ★】zx.br_full：上一秒是否"满"。只有 0→1 且冷却好了才进入。
# 【★ 满的判据 ★】fm_u == fm_c 且 fm_c ≥ 1（上限为 0 时不算满 —— 那是异常态）。
# 【★ 冷却 -10% 不在这里做 ★】见 bearing/on_cast：对"刚进入冷却的那个技能"减时长。
# ============================================================

# 套装门控：头上必须是「枢」
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run return 0

# 满了吗
scoreboard players set #br_full zx.meta 0
execute if score @s zx.fm_c matches 1.. if score @s zx.fm_u = @s zx.fm_c run scoreboard players set #br_full zx.meta 1

# 未满：清边沿记录就收工
execute if score #br_full zx.meta matches 0 run scoreboard players set @s zx.br_full 0
execute if score #br_full zx.meta matches 0 run return 0

# 已经满着（上秒也满）→ 不重复触发
execute if score @s zx.br_full matches 1 run return 0
scoreboard players set @s zx.br_full 1

# 12 秒冷却
execute if score @s zx.br_cd > #now manacore.meta run return 0

# 进入「阵成」：8 秒
scoreboard players operation @s zx.br_zc = #now manacore.meta
scoreboard players add @s zx.br_zc 160
scoreboard players operation @s zx.br_cd = #now manacore.meta
scoreboard players add @s zx.br_cd 240

tellraw @s [{"text":"「阵成」","color":"gold"},{"text":"  术阵位全满 —— 技能伤害 +15%、技能冷却 −10%","color":"gray"}]
particle minecraft:end_rod ~ ~1 ~ 0.8 0.6 0.8 0.05 20 normal
playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.5 1.6
'''

F['equipment/armor/bearing/on_cast.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/bearing/on_cast —— 「阵成」期间技能冷却 −10%（cooldown_start）
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start（前置包在**冷却写入之后**抛出，
#   此刻正在冷却的那个技能已经落盘，读 get 拿到的就是本次总时长）
# 【执行者】施法者（玩家）
# 【★ 为什么不写 stats.cooldown_reduction ★】那条属性被 upgrade/api/cd_stat 独占：
#   它每次结算都会**整体覆盖**（reduction_set），我们写进去会被下一秒抹掉，
#   而且会连带改掉别人武器的冷却缩减。这里改成"对这一个技能 reduce 10%"。
# 【★ reduce 的单位是 tick ★】remaining/10 就是 10%（整数除法，最多差 1 刻）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.br_zc > #now manacore.meta run return 0
execute unless data storage manacore:ctx skill run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 读该技能本次冷却总长
data modify storage zx:work cd.skill set from storage manacore:ctx skill
data modify storage manacore:in arg set value {uuid:"",skill:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work cd.skill
function manacore:api/cooldown/get

scoreboard players set #br_rem zx.meta 0
execute store result score #br_rem zx.meta run data get storage manacore:out r.remaining
execute if score #br_rem zx.meta matches ..9 run return 0
scoreboard players set #br_10 zx.meta 10
scoreboard players operation #br_rem zx.meta /= #br_10 zx.meta

data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work cd.skill
execute store result storage manacore:in arg.ticks int 1 run scoreboard players get #br_rem zx.meta
function manacore:api/cooldown/reduce
'''

F['equipment/armor/bearing/refund.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/bearing/refund —— 术阵减少时返还 25 魔力/个（每秒）
# ------------------------------------------------------------
# 【执行者】玩家（已确认穿着「承」且套装成立）
# 【文案】"术阵自然结束或被主动归还时，返还 25 点魔力值。"
# 【★ 判据 = 占用数下降 ★】zx.br_fm 记上一秒的 zx.fm_u（注意 lib/fm/read 已经在本函数
#   之前跑完，所以 @s zx.fm_u 是**本秒**的值）。
# 【★ 上限夹取交给 manacore ★】mana/add 内部会夹到最大魔力，不需要自己判。
# ============================================================

# 【★ 套装成立才返还 ★】这段文案在 lore 里属于「✦ 套装效果」段 ⇒ 和「阵成」一样
#   要求「枢」在头。没穿枢的时候把基线同步住（否则重新戴枢的那一秒会补发一笔）。
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run return 0

# 第一次跑（没记录）⇒ 只记基线，不返还
execute unless score @s zx.br_fm matches 0.. run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute unless score @s zx.br_fm matches 0.. run return 0

# 掉了几个（本秒比上秒少）
scoreboard players set #br_drop zx.meta 0
scoreboard players operation #br_drop zx.meta = @s zx.br_fm
scoreboard players operation #br_drop zx.meta -= @s zx.fm_u
execute if score #br_drop zx.meta matches ..0 run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute if score #br_drop zx.meta matches ..0 run return 0

# 25 × 掉的数量
scoreboard players set #br_25 zx.meta 25
scoreboard players operation #br_drop zx.meta *= #br_25 zx.meta

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage zx:work mr.value set value 0.0
execute store result storage zx:work mr.value double 1 run scoreboard players get #br_drop zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work mr.value
function manacore:api/mana/add

tellraw @s [{"text":"术阵结束，返还魔力值","color":"aqua"}]
scoreboard players operation @s zx.br_fm = @s zx.fm_u
'''

F['equipment/armor/bearing/hook_calc.mcfunction'] = r'''# @calc: indep — 套装「阵成」期间技能伤害 +15%（独立乘区）
# ============================================================
# sweetdream:equipment/armor/bearing/hook_calc —— 「阵成」的 15% 独立乘区
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc（排在 lib/dmg_add_apply 之后）
# 【执行者】施法者（玩家）
# 【★ 为什么乘 r.damage 而不是往加算池写 ★】文案明写"独立乘区" ⇒ 必须乘在**最终**
#   伤害上；加算池是"非独立"的通道加成（口径见 lib/dmg_add_apply 头部）。
#   写法与 glimmer/hook_calc（白光 +30% 独立）逐字同源。
# 【★ 只在阵成期间 ★】zx.br_zc = 阵成的到期刻；`> #now` 表示还在生效。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.br_zc > #now manacore.meta run return 0

scoreboard players set #brc zx.meta 0
execute store result score #brc zx.meta run data get storage manacore:out r.damage 1000
scoreboard players set #brk zx.meta 115
function manacore:internal/damage/mul_pct {src:"#brc",mul:"#brk",obj:"zx.meta"}
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta
'''

for rel, txt in F.items():
    p = os.path.join(FN, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(txt)
    print('wrote', rel)
print('total', len(F))

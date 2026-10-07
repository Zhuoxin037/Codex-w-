# ============================================================
# sweetdream:equipment/armor/brain_leech/passive —— 脑髓蛭的被动结算
# ------------------------------------------------------------
# 【执行者】玩家(由 second 逐个 as @a 调进来)
# 【文案上写的(普通)】
#   ① 自身魔力值上限 -120
#   ② 自身每秒额外恢复 3 点魔力值
#   ③ 当魔力值满后, 自身基础攻击力增加相当于自身魔力值上限 *0.03 的值
# 【★ 超限(2026-10-07): 戴着的那顶是「超限·脑髓蛭」时整条换挡 ★】
#   ② 回魔 3 -> 5; ③ 系数 0.03 -> 0.05; 另外多两样:
#   ④ 每次攻击(见 attack/atk_full, 由进度驱动)加一层「蛊虫」+ 5 秒定时攻击力
#   ⑤ 「蛊虫」满 10 层后转入**消耗模式**(atk_consume): 只消耗、不再累积,
#      每次攻击给 10 秒更强的定时攻击力(且**不要求魔力满**)。掉到 0 层退出该模式。
# 【认装备统一用 ~ 部分匹配 + 独有标记】custom_data~{zx:["brain_leech"]}
#   用 = (精确匹配)会"多一段少一段就整个对不上"且不报错(踩过两次)。
# 【③ 为什么要同时改两个地方】
#   原版属性 minecraft:attack_damage —— 真的会让平砍变疼;
#   面板 base_attack             —— 技能伤害公式读的是它(join 时快照了一次,
#                                   之后不会自己跟着属性变), 不改技能吃不到。
#   这两条是两条独立路径, 不会重复计算。
# 【定时加成怎么落】#want 里把"基础 + 定时(未过期)"都算进去, 再走同一本账
#   (zx.bl_atk)做差值 —— 所以定时那段到期后自然会被减回去, 不需要单独的清理。
# 【★ 关于 -120 把上限算成负数 ★】本件的上限是减的, 而框架基础的 max_mana
#   只有 100 —— 两件一起穿(它们就是一套)会算出 -200。这个由
#   sweetdream:lib/mana_floor 兜底(每秒最后把上限托到 20), 本件不做夹取:
#   自己夹会让"脱下别的装备"时本件反过来补上限, 越补越乱。
# ============================================================

# ① 拿 UUID(往面板写东西要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 戴没戴 / 戴的是不是超限版
scoreboard players set #bl_on zx.meta 0
execute if items entity @s armor.head diamond_helmet[custom_data~{zx:["brain_leech"]}] run scoreboard players set #bl_on zx.meta 1
scoreboard players set #bl_ol zx.meta 0
execute if items entity @s armor.head diamond_helmet[custom_data~{ol:"brain_leech"}] run scoreboard players set #bl_ol zx.meta 1

# ③ 每秒额外回魔: 用前置包的"恢复修正"槽位, 只在**值变了**的时候重挂
#    ⚠️ 不能每秒 add 一次 —— 同一个 id 重复 add 会占满 8 个槽位;
#       也不能只在"戴上/脱下"两个瞬间挂 —— 普通版 <-> 超限版换头时数值变了,
#       不重挂就永远停在旧值(3)。
scoreboard players set #rv zx.meta 0
execute if score #bl_on zx.meta matches 1 run scoreboard players set #rv zx.meta 3
execute if score #bl_ol zx.meta matches 1 run scoreboard players set #rv zx.meta 5
execute unless score #rv zx.meta = @s zx.bl_rv run function sweetdream:equipment/armor/brain_leech/regen_set

# ④ 魔力上限 -120(账本 zx.bl_mana, 只加差值)
scoreboard players set #want zx.meta 0
execute if score #bl_on zx.meta matches 1 run scoreboard players set #want zx.meta -120
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.bl_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/brain_leech/apply_mana

# ⑤ 没戴就把「蛊虫」/定时加成清干净(戴着不管, 让它们按自己的规则走)
execute if score #bl_on zx.meta matches 0 run scoreboard players set @s zx.bl_gu 0
execute if score #bl_on zx.meta matches 0 run scoreboard players set @s zx.bl_gm 0
execute if score #bl_on zx.meta matches 0 run scoreboard players set @s zx.bl_ta 0
execute if score #bl_on zx.meta matches 0 run scoreboard players set @s zx.bl_te 0

# ⑥ 读一次魔力, 判断"满不满"
#    ⚠️ 上限为 0 或负数时不算满(matches 1.. 的守卫), 免得"空血也算满"。
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #mana zx.meta run data get storage manacore:out r.value
execute store result score #mana_max zx.meta run data get storage manacore:out r.max
scoreboard players set #full_mana zx.meta 0
execute if score #mana_max zx.meta matches 1.. if score #mana zx.meta >= #mana_max zx.meta run scoreboard players set #full_mana zx.meta 1

# ⑦ 基础攻击力加成 = floor(魔力上限 × 系数 / 100)
#    系数: 3(普通) / 5(超限)
scoreboard players set #coef zx.meta 3
execute if score #bl_ol zx.meta matches 1 run scoreboard players set #coef zx.meta 5
scoreboard players set #want zx.meta 0
execute if score #bl_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta = #mana_max zx.meta
execute if score #bl_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta *= #coef zx.meta
execute if score #bl_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta /= #100 zx.meta

# ⑧ 再叠上"定时加成"(超限的攻击奖励, 未过期才有效)
execute if score #bl_on zx.meta matches 1 if score @s zx.bl_te > #now manacore.meta run scoreboard players operation #want zx.meta += @s zx.bl_ta

# ⑨ 差值落地
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.bl_atk
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/brain_leech/apply_atk

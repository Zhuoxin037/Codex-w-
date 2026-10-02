# ============================================================
# sweetdream:equipment/armor/brain_leech/passive —— 脑髓蛭的被动结算
# ------------------------------------------------------------
# 【执行者】玩家(由 second 逐个 as @a 调进来)
# 【文案上写的】
#   ① 自身魔力值上限 -120
#   ② 自身每秒额外恢复 3 点魔力值
#   ③ 当魔力值满后, 自身基础攻击力增加相当于自身魔力值上限 *0.03 的值
# 【认装备统一用 ~ 部分匹配 + 独有标记】custom_data~{zx:["brain_leech"]}
#   用 = (精确匹配)会"多一段少一段就整个对不上"且不报错(踩过两次)。
# 【③ 为什么要同时改两个地方】
#   原版属性 minecraft:attack_damage —— 真的会让平砍变疼;
#   面板 base_attack             —— 技能伤害公式读的是它(join 时快照了一次,
#                                   之后不会自己跟着属性变), 不改技能吃不到。
#   这两条是两条独立路径, 不会重复计算。
# 【★ 关于 -120 把上限算成负数 ★】本件的上限是减的, 而框架基础的 max_mana
#   只有 100 —— 两件一起穿(它们就是一套)会算出 -200。这个由
#   sweetdream:lib/mana_floor 兜底(每秒最后把上限托到 20), 本件不做夹取:
#   自己夹会让"脱下别的装备"时本件反过来补上限, 越补越乱。
# ============================================================

# ① 拿 UUID(往面板写东西要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 戴没戴
scoreboard players set #bl_on zx.meta 0
execute if items entity @s armor.head diamond_helmet[custom_data~{zx:["brain_leech"]}] run scoreboard players set #bl_on zx.meta 1

# ③ 每秒额外回 3 点魔力: 用前置包的"恢复修正"槽位, 只在状态翻转时挂/摘
#    ⚠️ 不能每秒 add 一次 —— 同一个 id 重复 add 会占满 8 个槽位。
execute if score #bl_on zx.meta matches 1 if score @s zx.bl_regen matches 0 run function sweetdream:equipment/armor/brain_leech/regen_add
execute if score #bl_on zx.meta matches 0 if score @s zx.bl_regen matches 1.. run function sweetdream:equipment/armor/brain_leech/regen_remove

# ④ 魔力上限 -120(账本 zx.bl_mana, 只加差值)
scoreboard players set #want zx.meta 0
execute if score #bl_on zx.meta matches 1 run scoreboard players set #want zx.meta -120
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.bl_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/brain_leech/apply_mana

# ⑤ 读一次魔力, 判断"满不满"
#    ⚠️ 上限为 0 或负数时不算满(matches 1.. 的守卫), 免得"空血也算满"。
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #mana zx.meta run data get storage manacore:out r.value
execute store result score #mana_max zx.meta run data get storage manacore:out r.max
scoreboard players set #full_mana zx.meta 0
execute if score #mana_max zx.meta matches 1.. if score #mana zx.meta >= #mana_max zx.meta run scoreboard players set #full_mana zx.meta 1

# ⑥ 魔力满 -> 基础攻击力 += floor(魔力上限 * 0.03)
#    上限 ×3 ÷100 就是 ×0.03, 全程整数运算, 不会出现小数属性。
scoreboard players set #want zx.meta 0
execute if score #bl_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta = #mana_max zx.meta
execute if score #bl_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta *= #3 zx.meta
execute if score #bl_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta /= #100 zx.meta
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.bl_atk
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/brain_leech/apply_atk

# ============================================================
# sweetdream:equipment/bow/bone_erode/shot —— 每次射击(蚀骨)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/bone_erode(触发器 shot_crossbow)。
# 【文案(基础版)】消耗 = 本次射击所消耗魔力值的 20%; 对被射击生物 2 格内的全部生物
#   造成 本次射击所消耗魔力值 ×0.4 的**伤害**。
# 【文案(超限·蚀骨, 2026-10-10 实装)】同上, 但 ×0.4 -> **×0.5** 且改打**真实伤害**;
#   另外"若生物上附有「噬心」则额外受到一次相当于本次伤害 80% 的真实伤害, 之后清除
#   「噬心」"。机制落在 fire ④⑤ + ol_shixin / ol_consume, 本文件只负责"把这一发
#   是不是超限版"随快照带过去。
# 【"本次射击所消耗的魔力值"取多少】= **自身当前魔力上限 × 20%**(lore 写的就是
#   「魔力 20%」, 基数 = 上限, 已含盔甲/临时上限加成 —— 那些是直接加进 stats.max_mana 的)。
# 【★ 2026-10-10 修: 原来这里写死 100 ★】lore 写「魔力 20%」而代码硬编码 100 ⇒
#   玩家换装备改了上限之后"射一发还是固定 100 蓝"(上限正好 500 时 20%=100, 巧合对上,
#   所以平时看不出来)。★ 同族「幽匿残响」的 lore 写「魔力 100」(固定值, 不是百分比),
#   那个写死 100 是对的 —— **只有蚀骨是百分比**, 别顺手把那边也改成百分比。
# 【★ 魔力是射出去之后才扣的 ★】和寒鸦同理: 射击事件发生在箭离弦之后,
#   所以只能"没蓝就不生效"(提示一句), 不可能"没蓝就不射"。
# 【这一发怎么和"打中了谁"对上】交给弩上的附魔「蚀骨」回调(hook_victim),
#   原版判断"这支箭打中了生物"。命中前把这一发的伤害/归属写进射手名下 +
#   逐箭快照(和寒鸦同一套)。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/bone_erode
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 本次射击消耗 = 当前魔力上限 × 20%
# 【口径】#be_cost 是 **×100 定点**(= 实际消耗 × 100), 下游统一用 double 0.01 还原。
#   推导: data get … 100 拿到 上限×100 → ×20 → ÷100 ⇒ 上限×20 = (上限×0.2)×100。
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #be_cost zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #be_cost zx.meta *= #20 zx.meta
scoreboard players operation #be_cost zx.meta /= #100 zx.meta

# ①' 这一发是不是**超限版**(蚀骨敲过超限石 -> custom_data 里 `ol:"bone_erode"`)
#   ★ 玩家物品 NBT 只能读不能写, 这里只"读"。
#   ★ 为什么必须在**离弦这一刻**拍下来: 命中结算要等"箭落地那一刻"才跑, 那时手里
#     拿的未必还是这把弩(可能换了武器、甚至换人了) ⇒ 判定得随快照一路带到命中点。
#   ★ 只判 mainhand: 弩是武器, `shot_crossbow` 本来就是"手持那把"触发, 双持以主手为准
#     (与寒鸦 ol_refill 的判据同款)。
scoreboard players set #be_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["bone_erode"],ol:"bone_erode"}] run scoreboard players set #be_ol zx.meta 1

# ② 扣魔力: 实际消耗 = #be_cost ÷ 100(定点还原)
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.01 run scoreboard players get #be_cost zx.meta
function manacore:api/mana/consume

# ③ 魔力不足 -> 这一发什么都不做(清掉旧数据, 免得命中时读到上一发)
execute if data storage manacore:out r{success:0b} run data modify storage zx:work be.uuid set from storage zx:data self.uuid
execute if data storage manacore:out r{success:0b} run function sweetdream:equipment/bow/bone_erode/clear with storage zx:work be
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭没有蚀骨效果","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 把这一发的数据记在射手名下, 再写进这一箭自己身上(逐箭快照)
#    dmg = 本次消耗 ×0.4(基础版) / ×0.5(超限版)
#          #be_cost = 消耗×100 ⇒ dmg = #be_cost × 0.004 / ×0.005
#    ol  = 这一发走不走超限那条结算(真实伤害 + 「噬心」追击)
#    (上限 500 时: 消耗 100 → dmg 40 / 50, 与旧的"写死 100"数值一致)
data modify storage zx:work be set value {uuid:"",dmg:0.0,ol:0b,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work be.uuid set from storage zx:data self.uuid
execute store result storage zx:work be.dmg double 0.004 run scoreboard players get #be_cost zx.meta
execute if score #be_ol zx.meta matches 1 run execute store result storage zx:work be.dmg double 0.005 run scoreboard players get #be_cost zx.meta
execute store result storage zx:work be.ol byte 1 run scoreboard players get #be_ol zx.meta
execute store result storage zx:work be.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work be.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work be.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work be.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/bone_erode/store with storage zx:work be
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/bone_erode/snapshot with storage zx:work be

# ⑤ 表现: 骨屑
execute at @s run particle minecraft:item{item:"minecraft:bone"} ~ ~1.3 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.4

# ⑥ 「启示录」记页: 蚀骨的射击也是「✦ 主动技能」, 但弩没有冷却、不抛 cooldown_start,
#    只能在这里显式补一枪(见 apocalypse/spend)。放在最后: spend 会读 uuid / 写公共输入口, 别打断上面还在用的数据。
function sweetdream:equipment/staff/apocalypse/spend

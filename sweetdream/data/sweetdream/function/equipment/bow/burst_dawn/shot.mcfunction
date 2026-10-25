# ============================================================
# sweetdream:equipment/bow/burst_dawn/shot —— 每次射击(爆裂黎明)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/burst_dawn(触发器 shot_crossbow)。
#   与其余 8 把弩同一套: 进度 -> shot -> 处理 -> 给刚射出的箭打标记。
#   (坑 125: 弩**必须**有这一环, 否则 lore 上的「魔力 799」永远不会扣。)
# 【技能原文(lore 逐字, 按它分段实现)】
#   「射击后召唤一个术阵。在自身位置周围召唤两个生命值为 100 可持续 20 秒的
#    「魂灵之影」，其每 3 秒都会对其 3 格内的一个生物造成相当于其当前生命值
#    ×0.5 的伤害并使其获得 1 秒缓慢Ⅱ。若生物索敌为自身，则会转移索敌至
#    「魂灵之影」。自身对射中的生物及其 3 格内的全部生物造成一次相当于自身
#    基础攻击力 ×8 + 自身最大魔力值 ×0.15 的伤害并使生物获得 2 秒缓慢Ⅴ，
#    之后再造成一次相当于上次总伤害 50% 的伤害。之后自身可以使用自身召唤的
#    「魂灵之影」当作弹药继续进行轰击，但是伤害变为自身基础攻击力 ×4 + 自身
#    最大魔力值 ×0.08。场上不存在自身召唤的「魂灵之影」后则该技能结束。」
# 【★ 首发 / 续轰怎么分 ★】
#   场上**还有没有属于我自己的魂灵之影** —— 有 = 这一发是"续轰"(不扣魔力, 吃
#   掉一只影当弹药); 没有 = 这一发是"首发"(扣 799 魔力, 起术阵 + 召两个影)。
#   判据是**当场数实体**(不是玩家级账本), 所以影被怪打死 / 自然到期 / 换维度
#   都不会让计数说谎(坑 107: 玩家级单标量存不了"还有几件")。
# 【★ 为什么两个影能撑两发续轰 ★】首发召 2 只 -> 第一发续轰吃掉 1 只(剩 1)
#   -> 第二发续轰吃掉最后 1 只(剩 0) -> 再射击就又是"首发"(重新扣 799)。
#   这就是文案说的"场上不存在自身召唤的魂灵之影后则该技能结束"。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/burst_dawn
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

function sweetdream:equipment/bow/burst_dawn/visual/shot
# ⓪ 旧弩自检(坑 144)
#   弩**没有** consumable / 右键, 命中结算全靠 enchantment 的 post_attack 回调
#   (坑 138: 回调只读攻击者**主手物品**上的附魔)。手上的弩若是"加附魔之前"give
#   出来的旧版本, 物品 NBT 里就没有那个附魔 => 回调一次都不会触发 => 表现是
#   "魔力照扣、术阵照起, 但命中伤害一点都没有", 而且**零日志**, 极难排查。
#   ★ 物品 NBT 是快照: /reload 也好、退世界重进也好, 都不会让它自己长出来 ——
#     只能重新 give。所以在每次射击时自查一次并明说。
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「爆裂黎明」是旧版本(没有机制附魔) —— 命中伤害不会生效, 请重新 give 一把","color":"red"}]

# ① 先数场上还有几只"我自己的"影 —— 有就地在 ammo 里吃掉一只当弹药(不扣魔力)。
#    【★ 分流判据只能读 #bd_hit, 不能读 #bd_n ★】ammo 内部还会用 #bd_n / #bd_left
#    做"吃掉前几只 / 吃掉后剩几只", 拿 #bd_n 当分流判据会被那条收尾计数覆盖成 0
#    => 吃掉最后一只的那一发会紧接着再走一遍"首发"(坑 143)。
#    【判据是**当场数实体**(不是玩家级账本)】影被怪打死 / 自然到期 / 换维度
#    都不会让计数说谎(坑 107)。
data modify storage zx:work bd.uu set from storage zx:data self.uuid
function sweetdream:equipment/bow/burst_dawn/ammo with storage zx:work bd
execute if score #bd_hit zx.meta matches 1.. run return 0

# ② 首发: 扣魔力 799(与 lore 的「魔力 799」逐字对应)
data modify storage manacore:in arg set value {uuid:"",value:799.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.bd_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 「爆裂黎明」无法启爆（需要 799）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ②.5 记下"这一发付过账" + 走主力口径(**写在射手身上**, 坑 141: 箭上的标签靠不住)
scoreboard players set @s zx.bd_paid 1
scoreboard players set @s zx.bd_mode 1

# ③ 术阵 + 两个魂灵之影 + 给箭打"主力"标记
execute store result storage zx:work bd.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work bd.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work bd.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work bd.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/burst_dawn/cast with storage zx:work bd

# ④ 表现
execute at @s run particle minecraft:flash ~ ~1.2 ~ 0 0 0 0 1 normal
execute at @s run particle minecraft:soul ~ ~1.2 ~ 1.2 0.8 1.2 0.05 40 normal
execute at @s run playsound minecraft:entity.iron_golem.attack player @a ~ ~ ~ 0.6 1.6
execute at @s run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.8 0.6

# ⑤ 「启示录」记页(与其余弩同款)
function sweetdream:equipment/staff/apocalypse/spend

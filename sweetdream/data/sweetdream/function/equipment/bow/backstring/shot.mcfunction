# ============================================================
# sweetdream:equipment/bow/backstring/shot —— 每次射击(退弦)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/backstring(触发器 shot_crossbow)。
#   与其余 9 把弩同一套: 进度 -> shot -> 扣蓝 -> 记"这一发付过账"。
#   (坑 125: 弩**必须**有这一环, 否则 lore 上的「魔力 30」永远不会扣。)
# 【技能原文(lore 逐字)】✦ 主动技能 / ✦ 弦满 两段
#   (耗蓝不在正文里 —— 写在主动技能段的拼色行「魔力 30」上)
#   「箭矢命中后，自身向后位移 2 格并获得 2 秒迅捷Ⅱ。」
#   「每累计 3 次射击，第 3 发额外造成 12 点伤害。」
# 【扣蓝口径】与寒鸦/电弧/龙舌一致: **离弦那一刻**扣 30 —— 没射中也要付钱;
#   没蓝 -> 这一发不位移(命中回调自然收工), 提示一句。
# 【★ 计数按"射击事件"计, 不按"命中"计 ★】文案是"每累计 3 次射击", 不是
#   "每 3 次命中"。多重射击 3 支箭也只算 1 次射击(进度只触发一次)。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/backstring
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144)
#   弩没有 consumable / 右键, 命中结算全靠 enchantment 的 post_attack 回调
#   (坑 138: 回调只读攻击者**主手物品**上的附魔)。手上的弩若是"加附魔之前"give
#   出来的旧版本, 物品 NBT 里就没有那个附魔 => 回调一次都不会触发 => 表现是
#   "魔力照扣, 但后撤 / 保底伤害一点都没有", 而且**零日志**, 极难排查。
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「退弦」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ① 扣魔力(固定 30 —— 与 lore 的「魔力 30」逐字对应)
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume

# ② 魔力不足 -> 这一发不生效
#   ★ 必须把"这一发付过账"**显式写成 0**(坑 141): 命中回调读的是**射手身上**的
#     zx.bs_paid, 而它在射下一发之前不会自己归零 —— 不清掉的话, "上一发付过钱"
#     会让"这一发没蓝"的箭照样后撤。
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.bs_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭无法拉开「退弦」","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"(**写在射手身上**, 不写在箭上 —— 见坑 141)
scoreboard players set @s zx.bs_paid 1

# ④ 射击计数 +1; 满 3 -> 置"这一发带保底伤害", 计数归零
#   【乘区/保底不用别的计分项】一个计分项只代表一件事(坑 136/143):
#     zx.bs_n    = 已射击次数(0..2)
#     zx.bs_ready= "下一发命中要打 12 点" —— 命中结算时读它, 读完清 0
scoreboard players add @s zx.bs_n 1
execute if score @s zx.bs_n matches 3.. run scoreboard players set @s zx.bs_ready 1
execute if score @s zx.bs_n matches 3.. run scoreboard players set @s zx.bs_n 0

# ⑤ 表现: 弦上退回的一缕风
execute at @s run particle minecraft:small_gust ~ ~1.2 ~ 0.2 0.2 0.2 0.02 6 normal

# ⑥ 「启示录」记页(与其余弩同款)
function sweetdream:equipment/staff/apocalypse/spend

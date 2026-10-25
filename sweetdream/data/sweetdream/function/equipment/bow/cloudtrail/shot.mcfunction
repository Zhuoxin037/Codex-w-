# ============================================================
# sweetdream:equipment/bow/cloudtrail/shot —— 每次射击(云迹)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/cloudtrail(触发器 shot_crossbow)。
# 【技能原文(lore 逐字)】
#   「射击后若未射中生物，则在箭停留位置生成一个持续 5 秒的半径 3 格的领域。
#    当自身射击在领域内的生物时会同步对领域内的全部生物造成一次相当于
#    自身基础攻击力 ×2 的伤害。」
# 【扣蓝口径】与其余弩一致: **离弦那一刻**扣 30 —— 没射中也要付钱(而"没射中"
#   恰恰是本技能要判的情况, 更不能"没蓝就不给领域")。没蓝 -> 这一发不生效。
# 【这一发要交给箭两样东西】
#   zx.ct_paid 射手身上的一句"这发付过钱"(命中门控读它; 没蓝那一发写成 0)
#   zx.ct_live 驱动标签: core/tick 每刻扫它 + inGround:1b 判"落地了没"(见那里的注释)
#   data.zx.ct.uu  射手的 uuid **文本** —— 箭落地后要在箭的位置建"自己的"领域,
#                  而落地那一刻手里拿的是什么、人还在不在都不保证, 所以 uuid 必须
#                  随箭走(和寒鸦"逐箭快照"同一套思路)。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/cloudtrail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144)
#   弩**没有** consumable / 右键, 命中结算全靠 enchantment 的 post_attack 回调
#   (坑 138: 回调只读攻击者**主手物品**上的附魔)。手上的弩若是"加附魔之前"give
#   出来的旧版本, 物品 NBT 里就没有那个附魔 => 回调一次都不会触发 => 表现是
#   "魔力照扣, 但领域 / 同步伤害一点都没有", 而且**零日志**, 极难排查。
#   ★ 物品 NBT 是快照: /reload 也好、退世界重进也好, 都不会让它自己长出来 ——
#     只能重新 give。所以在每次射击时自查一次并明说。
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「云迹」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ① 扣魔力(固定 30 —— 与 lore 的「魔力 30」逐字对应)
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay

# ② 魔力不足 -> 这一发不生效(没有领域可建), 并且**显式把两个状态写成 0**
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.ct_paid 0
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.ct_seek 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭无法留下「云迹」","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"(**写在射手身上** —— 坑 141: 箭上的标签靠不住)
scoreboard players set @s zx.ct_paid 1

# ④ 把射手 uuid 写进箭自己(data.zx.ct.uu) —— 领域必须建在**箭停留的位置**
#    【★ 认箭是个有风险的活 ★】射击那一刻箭可能还没进世界, 这里就认不到。
#    所以: ① 这里先试一次(认到最好) ② 认不到就靠 zx.ct_seek 开一个 3 刻的
#    补认窗口, 由 core/tick 在打 cc_seen **之前**再补认一次(见 arrow_seek)。
#    两条路都写进 data.zx.ct, 谁先认到算谁的(写了 ok:1b 之后就不会重复写)。
scoreboard players set @s zx.ct_seek 3
data modify storage zx:work ctm.uu set from storage zx:data self.uuid
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/cloudtrail/arrow_mark with storage zx:work ctm

# ④ 表现
execute at @s run particle minecraft:cloud ~ ~1.2 ~ 0.2 0.2 0.2 0.01 6 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.0

# ⑤ 「启示录」记页(与其余弩同款)
function sweetdream:equipment/staff/apocalypse/spend

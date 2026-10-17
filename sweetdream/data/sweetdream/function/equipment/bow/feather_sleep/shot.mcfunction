# ============================================================
# sweetdream:equipment/bow/feather_sleep/shot —— 每次射击(眠羽)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/feather_sleep(触发器 shot_crossbow)。
#   与其余 10 把弩同一套: 进度 -> shot -> 扣蓝 -> 给"这一发付过账"打标记。
#   (坑 125: 弩**必须**有这一环, 否则 lore 上的「魔力 80」永远不会扣。)
# 【文案】魔力 80。每次射击命中了附有「白昼梦」的生物后, 消耗其「白昼梦」,
#   并使箭矢分裂出 2 枚半透明的羽箭。羽箭分别追踪命中位置 6 格内最近的其他生物,
#   对其造成一次相当于自身最大魔力值 ×0.08 的伤害, 并使其获得 3 秒缓慢Ⅱ。
#   若只有一个生物, 则 2 枚羽箭合为一枚, 伤害改为相当于自身最大魔力值 ×0.18。
# 【扣蓝口径】与龙舌/蚀骨一致: **离弦那一刻**扣 80 —— 没射中也要付钱;
#   没蓝 -> 这一发不生效(zx.fs_paid 写成 0, 命中回调自然收工), 提示一句。
# 【这一发怎么和"打中了谁"对上】命中判定交给弩上的附魔「眠羽」
#   (enchantment/feather_sleep.json 的 post_attack 三回调)。坑 138: 回调只读
#   攻击者**主手物品**上的附魔 ⇒ 本件必须挂 enchantments, 否则整把弩静默失效。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/feather_sleep
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144)
#   手上那把若是"加附魔之前"give 出来的旧版本, 物品 NBT 里没有机制附魔 =>
#   回调一次都不触发 => 表现是"蓝照扣, 但白昼梦不消、没有羽箭", 而且**零日志**。
#   ★ 物品 NBT 是快照, /reload 与退世界重进都不会让它自己长出来 —— 只能重新 give。
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「眠羽」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ① 扣魔力(固定 80 —— 与 lore 的「魔力 80」逐字对应)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume

# ② 魔力不足 -> 这一发不附加任何效果
#   ★ 必须把"这一发付过账"**显式写成 0**(坑 141): 命中回调读的是**射手身上**的
#     zx.fs_paid, 它在射下一发之前不会自己归零 —— 不清掉的话"上一发付过钱"
#     会让"这一发没蓝"的箭照样结算。
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.fs_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭不会分裂出羽箭","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"(写在**射手身上**, 不写在箭上 —— 见坑 141)
scoreboard players set @s zx.fs_paid 1

# ④ 表现: 弦上一片羽毛
execute at @s run particle minecraft:item{item:{id:"minecraft:feather",count:1}} ~ ~1.2 ~ 0.25 0.25 0.25 0.02 6 normal
execute at @s run particle minecraft:cloud ~ ~1.2 ~ 0.2 0.2 0.2 0.01 4 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.6

# ⑤ 「启示录」记页(与其余 10 把弩同款; 本件固定消耗 80 < 100, 不会产生页, 但保持链路一致)
function sweetdream:equipment/staff/apocalypse/spend

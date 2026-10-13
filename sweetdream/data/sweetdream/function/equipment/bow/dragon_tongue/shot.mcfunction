# ============================================================
# sweetdream:equipment/bow/dragon_tongue/shot —— 每次射击(龙舌)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/dragon_tongue(触发器 shot_crossbow)。
#   与其余 6 把弩同一套: 进度 -> shot -> 扣蓝 -> 给刚射出的箭打"已付钱"标记。
#   (坑 125: 弩**必须**有这一环, 否则 lore 上的「魔力 60」永远不会扣。)
# 【技能原文(lore 逐字)】
#   「每次射击若射击附加了「夜火」效果的生物，则使其消除「夜火」并在其 2 格内
#     释放一次箭雨。每根箭的伤害相当于自身当前魔力值 ×X×0.01，箭的数量为 X×3。
#     X 为自身 6 格内附有「流火」或「夜火」的生物的数量。」
# 【扣蓝口径】与寒鸦/电弧一致: **离弦那一刻**扣 60 —— 没射中也要付钱;
#   没蓝 -> 这一发不生效(zx.dt_paid 写成 0, 命中回调自然收工), 提示一句。
# 【为什么给**箭**打标记】效果由附魔回调在"箭命中"时才跑, 那时手里拿的未必还是
#   这把弩 —— "这一发到底付没付钱"必须写在**箭自己**身上。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/dragon_tongue
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144)
#   弩**没有** consumable / 右键, 命中结算全靠 enchantment 的 post_attack 回调
#   (坑 138: 回调只读攻击者**主手物品**上的附魔)。手上的弩若是"加附魔之前"give
#   出来的旧版本, 物品 NBT 里就没有那个附魔 => 回调一次都不会触发 => 表现是
#   "魔力照扣, 但箭雨 / 消夜火一点都没有", 而且**零日志**, 极难排查。
#   ★ 物品 NBT 是快照: /reload 也好、退世界重进也好, 都不会让它自己长出来 ——
#     只能重新 give。所以在每次射击时自查一次并明说。
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「龙舌」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ① 扣魔力(固定 60 —— 与 lore 的「魔力 60」逐字对应)
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume

# ② 魔力不足 -> 这一发不附加任何效果
#   ★ 必须把"这一发付过账"**显式写成 0**(坑 141): 命中回调读的是**射手身上**的
#     zx.dt_paid, 而它在射下一发之前不会自己归零 —— 不清掉的话, "上一发付过钱"
#     会让"这一发没蓝"的箭照样结算(与寒鸦 clear 写 tier:0 同一个道理)。
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.dt_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭无法引燃「龙舌」","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"(**写在射手身上**, 不写在箭上 —— 见坑 141)
#   【★ 为什么不再给箭打标签 ★】`shot_crossbow` 进度的触发时机可能早于箭进世界,
#     那时 tag=!zx.cc_seen 的"新箭"根本不存在, 标签永远打不上 ⇒ 整把弩静默失效
#     (2026-10-12 用户实测"弩的效果根本不生效"就是这个)。射手身上的计分项没有
#     时序问题: 命中回调由 hook_victim 用 `execute on attacker` 回到射手身上读。
#   【多重射击】3 支箭共享同一个"付过账"状态, 各自命中时都能结算 —— 正合文案。
scoreboard players set @s zx.dt_paid 1

# ④ 表现: 弩弦上的火星
execute at @s run particle minecraft:flame ~ ~1.2 ~ 0.25 0.25 0.25 0.02 8 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.1

# ⑤ 「启示录」记页(与其余弩同款)
function sweetdream:equipment/staff/apocalypse/spend

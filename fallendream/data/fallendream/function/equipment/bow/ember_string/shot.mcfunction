# ============================================================
# fallendream:equipment/bow/ember_string/shot —— 每次射击(烬弦)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/bow/ember_string(触发器 shot_crossbow)。
# 【文案·原版】魔力 80。每次射击命中生物后 ——
#   · 未附有「流火」和「夜火」 -> 使其附加「流火」
#   · 附有「流火」而未附有「夜火」 -> 把「流火」转化为「夜火」
#   · 已附有「夜火」 -> 额外造成一次相当于自身最大魔力值 ×0.04 的伤害
#   该效果 8 秒内最多触发一次。
# 【文案·超限】魔力 100；分支③ 的伤害改 ×0.06；节流从"射手 8 秒整段"改成
#   "每个生物 4 秒"；另加"12 秒内三种效果都对它触发过 -> 再打一次 ×0.08 + 随机标签"。
# 【★ 2026-10-15 用户拍板: 节流的是**整段**效果(不是只有伤害段) ★】
#   ⇒ 闸门在 fire 一进来就判、一进来就续(原版在射手身上, 超限在受害者身上)。
# 【★ 魔力是射出去之后才扣的 ★】射击事件在箭离弦之后 ⇒ 只能"没蓝就不生效"。
# 【★ 超限档必须在**这一刻**拍下来 ★】命中回调里读不到射手当时拿的是什么
#   (那时箭已飞出、手可能已换) ⇒ 与 es_paid 同一层, 记在射手身上(坑 141)。
# ============================================================

advancement revoke @s only fallendream:equipment/bow/ember_string
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144): 没有机制附魔 = 命中回调一次都不触发(蓝照扣、什么都不发生)
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「烬弦」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ① 这一发是普通弩还是超限弩(快照, 记在射手身上)
scoreboard players set @s zx.es_ol 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["ember_string"],ol:"ember_string"}] run scoreboard players set @s zx.es_ol 1

# ② 扣魔力: 原版 80 / 超限 100
data modify storage manacore:in arg set value {uuid:"",value:80.0}
execute if score @s zx.es_ol matches 1 run data modify storage manacore:in arg.value set value 100.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay

# ③ 魔力不足 -> 这一发不生效(显式清掉付账标记, 坑 141)
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.es_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭不会引燃烬弦","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 记下"这一发付过账"(写在射手身上, 不写在箭上 —— 坑 141)
scoreboard players set @s zx.es_paid 1

# ⑤ 表现: 弦上火星
execute at @s run particle minecraft:flame ~ ~1.2 ~ 0.25 0.25 0.25 0.02 8 normal
execute at @s run particle minecraft:lava ~ ~1.2 ~ 0.15 0.15 0.15 0.0 3 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.3

# ⑥ 「启示录」记页(与其余弩同款)
function fallendream:equipment/staff/apocalypse/spend

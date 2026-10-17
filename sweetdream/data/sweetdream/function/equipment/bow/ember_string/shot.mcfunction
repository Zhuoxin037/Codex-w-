# ============================================================
# sweetdream:equipment/bow/ember_string/shot —— 每次射击(烬弦)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/ember_string(触发器 shot_crossbow)。
# 【文案】魔力 80。每次射击命中生物后 ——
#   · 未附有「流火」和「夜火」 -> 使其附加「流火」
#   · 附有「流火」而未附有「夜火」 -> 把「流火」转化为「夜火」
#   · 已附有「夜火」 -> 额外造成一次相当于自身最大魔力值 ×0.04 的伤害
#   该效果 8 秒内最多触发一次。
# 【★ 2026-10-15 用户拍板: 节流的是**整段**效果(不是只有伤害段) ★】
#   ⇒ 闸门(射手身上的 zx.es_gate)在 fire 一进来就判、一进来就续。
# 【★ 魔力是射出去之后才扣的 ★】射击事件在箭离弦之后 ⇒ 只能"没蓝就不生效"。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/ember_string
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144): 没有机制附魔 = 命中回调一次都不触发(蓝照扣、什么都不发生)
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「烬弦」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ① 扣魔力 80
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume

# ② 魔力不足 -> 这一发不生效(显式清掉付账标记, 坑 141)
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.es_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭不会引燃烬弦","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"(写在射手身上, 不写在箭上 —— 坑 141)
scoreboard players set @s zx.es_paid 1

# ④ 表现: 弦上火星
execute at @s run particle minecraft:flame ~ ~1.2 ~ 0.25 0.25 0.25 0.02 8 normal
execute at @s run particle minecraft:lava ~ ~1.2 ~ 0.15 0.15 0.15 0.0 3 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.3

# ⑤ 「启示录」记页(与其余弩同款)
function sweetdream:equipment/staff/apocalypse/spend

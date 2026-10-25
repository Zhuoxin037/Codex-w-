# ============================================================
# sweetdream:equipment/bow/reverse_string/shot —— 每次射击(逆弦)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/reverse_string(触发器 shot_crossbow)。
# 【文案】魔力 100。每次射击命中生物后 ——
#   额外造成一次相当于自身基础攻击力 ×2 的伤害。若自身当前魔力值不高于最大魔力值的
#   25%, 则该段技能伤害提高 50%(独立乘区); 若强化段击杀了生物, 则返还 40 魔力。
# 【★ 没有节流 ★】文案没写"多少秒内最多触发一次" ⇒ 每一发命中都结算。
# 【★ 魔力是射出去之后才扣的 ★】射击事件在箭离弦之后 ⇒ 只能"没蓝就不生效"。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/reverse_string
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144)
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「逆弦」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ⓪.5 这一发是不是超限版(主手这把带 ol:"reverse_string" —— 批 K7)
#   ★ 命中回调只认"这一发付没付过账"(zx.rs_paid), 拿不到"当时手里是哪把弩";
#     所以"超限"必须在这里写进玩家身上(与 bs_paid 同一层, 坑 141 同族)。
scoreboard players set @s zx.rs_ov 0
execute if items entity @s weapon.mainhand crossbow[custom_data~{ol:"reverse_string"}] run scoreboard players set @s zx.rs_ov 1

# ① 扣魔力(普通 100 / 超限 280)
data modify storage manacore:in arg set value {uuid:"",value:100.0}
execute if score @s zx.rs_ov matches 1 run data modify storage manacore:in arg.value set value 280.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay

# ② 魔力不足 -> 这一发不生效(显式清掉付账标记, 坑 141)
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.rs_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭不会触发逆弦","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"(写在射手身上, 不写在箭上 —— 坑 141)
scoreboard players set @s zx.rs_paid 1
# ④ 表现: 反向蓄能的冷蓝色弦光
execute at @s run particle minecraft:end_rod ~ ~1.2 ~ 0.2 0.25 0.2 0.0 6 normal
execute at @s run particle minecraft:electric_spark ~ ~1.2 ~ 0.2 0.25 0.2 0.01 5 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 0.9

# ⑤ 「启示录」记页(与其余弩同款)
function sweetdream:equipment/staff/apocalypse/spend

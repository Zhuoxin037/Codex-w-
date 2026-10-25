# ============================================================
# sweetdream:equipment/bow/dark_sun/shot —— 每次射击(黯日)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/dark_sun(触发器 shot_crossbow)。
# 【文案】魔力 320。每次射击命中生物后 ——
#   额外造成一次相当于自身当前魔力值 ×0.12 的伤害, 并使其附加「夜火」和「流火」。
#   若其已附有「流火」则上述伤害提高 30%; 若该目标在命中前已附有「夜火」则上述
#   伤害提高 50%(独立乘区), 并向命中位置 6 格内最近的四个其他生物释放一枚影矢
#   (影矢: 自身当前魔力值 ×0.08 的伤害 + 附加「夜火」)。
#   该效果 20 秒内最多触发一次。
# 【★ 节流是**整段**(2026-10-15 用户拍板) ★】⇒ 闸门在 fire 一进来就判、一进来就续。
#   注意「魔力 320」是**每一发**都扣的(节流的是命中后的效果, 不是扣蓝)。
#   ★ 超限(批 K7): 文案有意去掉节流 ⇒ 超限版每发 420 蓝、每发都完整结算。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/dark_sun
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 旧弩自检(坑 144)
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"⚠ 手上这把「黯日」是旧版本(没有机制附魔) —— 命中效果不会生效, 请重新 give 一把","color":"red"}]

# ⓪.5 这一发是不是超限版(主手这把带 ol:"dark_sun" —— 批 K7)
#   ★ 命中回调只认"这一发付没付过账"(zx.ds_paid), 拿不到"当时手里是哪把弩";
#     所以"超限"必须在这里写进玩家身上(与 ds_paid 同一层, 坑 141 同族)。
scoreboard players set @s zx.ds_ol 0
execute if items entity @s weapon.mainhand crossbow[custom_data~{ol:"dark_sun"}] run scoreboard players set @s zx.ds_ol 1

# ① 扣魔力(普通 320 / 超限 420)
data modify storage manacore:in arg set value {uuid:"",value:320.0}
execute if score @s zx.ds_ol matches 1 run data modify storage manacore:in arg.value set value 420.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay

# ② 魔力不足 -> 这一发不生效(显式清掉付账标记, 坑 141)
execute if data storage manacore:out r{success:0b} run scoreboard players set @s zx.ds_paid 0
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭不会引落黯日","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记下"这一发付过账"(写在射手身上, 不写在箭上 —— 坑 141)
scoreboard players set @s zx.ds_paid 1

# ④ 表现: 箭杆裹一层暗紫色日冕
execute at @s run particle minecraft:soul_fire_flame ~ ~1.2 ~ 0.25 0.25 0.25 0.02 8 normal
execute at @s run particle minecraft:dust{color:[0.45,0.18,0.62],scale:1.2} ~ ~1.2 ~ 0.25 0.25 0.25 0.0 6 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 0.8

# ⑤ 「启示录」记页(与其余弩同款; 本件固定消耗 320 >= 100, 会正常产生页)
function sweetdream:equipment/staff/apocalypse/spend

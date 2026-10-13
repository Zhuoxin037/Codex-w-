# ============================================================
# sweetdream:equipment/sword/crescent/slot —— 看一个快捷栏格(宏 {slot})
# ------------------------------------------------------------
# 【执行者】玩家   【宏参数】slot = 0..8(快捷栏下标)
# 【出参】zx:work cr.s = 该格物品的 skill id(该格没物品 / 那件没 skill -> 该键被删掉)
#         #cr_hit zx.meta = 1 / 0  "这一格算不算一条正在冷却的其它主动技能"
#   = 有 skill 且 不是缺月自己 且 冷却中(remaining > 0)
# 【★ 1.21.5 读法 ★】玩家穿戴在 equipment.*; 背包格仍在 Inventory[{Slot:Nb}]
#   (0..8 = 快捷栏)。见 debug/worn_slot 的头注释。
# 【★ 数字下标可以用宏 ★】`$(slot)` 只是往路径里插数字, 不是"拿宏当键名"(那不是坑 129
#   的反面: 坑 129 说的是宏参数找不到**键**; 这里键是模板里现成的 `Slot`)。
# ============================================================

data remove storage zx:work cr.s
$execute if data entity @s Inventory[{Slot:$(slot)b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:$(slot)b}].components."minecraft:custom_data".skill

scoreboard players set #cr_hit zx.meta 0
# 空格 / 没 skill -> 不算
execute unless data storage zx:work cr.s run return 0
# 缺月自己 -> 排除("不包括该武器")
execute if data storage zx:work cr{s:"sweetdream:crescent"} run return 0

# 查它冷却好没好(ready:1b = 就绪; ready:0b = 冷却中)
data modify storage manacore:in arg set value {uuid:"",skill:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work cr.s
function manacore:api/cooldown/get
execute unless data storage manacore:out r{ready:0b} run return 0

scoreboard players set #cr_hit zx.meta 1

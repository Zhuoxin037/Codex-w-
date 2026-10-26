# ============================================================
# api/mana/regen/get —— 查询魔力恢复参数
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>"}
#          function manacore:api/mana/regen/get
# 【出参】out.value      = 每秒基础恢复(默认 1.0)
#         out.multiplier = 恢复倍率(默认 1.0)
#         out.bonus      = 8 个修正槽位的合计(装备+被动+临时+特殊)
# 【实际每秒恢复量】= (value + bonus) x multiplier
# 【用途】属性面板显示"每秒恢复 X"。
# ============================================================
data modify storage manacore:work a set value {uuid:""}
data modify storage manacore:work a merge from storage manacore:in arg
execute if data storage manacore:work a.uuid run function manacore:internal/mana/regen_get with storage manacore:work a

execute if entity @s[type=minecraft:player,scores={zx.job=1}] run function sweetdream:profession/mage/regen_preview

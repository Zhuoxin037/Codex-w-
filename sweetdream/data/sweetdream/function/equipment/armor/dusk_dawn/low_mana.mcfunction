# ============================================================
# sweetdream:equipment/armor/dusk_dawn/low_mana —— 魔力低于上限 50% 时每秒回 20
# ------------------------------------------------------------
# 【文案】若自身魔力值低于魔力值上限 50% 则每秒获得 20 魔力值。
# 【怎么比"低于 50%"】把当前魔力 ×2 和上限比(避免做除法丢精度):
#   当前 ×2 < 上限  <=>  当前 < 上限的一半
# ============================================================

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #cur zx.meta run data get storage manacore:out r.value
execute store result score #max zx.meta run data get storage manacore:out r.max
scoreboard players operation #dbl zx.meta = #cur zx.meta
scoreboard players operation #dbl zx.meta *= #2 zx.meta
execute if score #dbl zx.meta < #max zx.meta run function sweetdream:equipment/armor/dusk_dawn/low_mana_add

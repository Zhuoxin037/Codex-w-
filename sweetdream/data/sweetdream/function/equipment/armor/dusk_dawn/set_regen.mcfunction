# ============================================================
# sweetdream:equipment/armor/dusk_dawn/set_regen —— 套装: 每 3 秒恢复 1% 魔力
# ------------------------------------------------------------
# 【执行者】穿着套装的玩家(由 second 每 3 秒挑一次)
# 【1% 怎么算】把上限按 x100 读成整数 -> 除以 100 回到原值 -> 再除以 100 取 1%。
#   两次整数除法的精度损失最多 1 点, 对这种"每 3 秒回一点"的效果足够了。
#   (计分板没有小数, 所以只能这么算)
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #mz zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #mz zx.meta /= #100 manacore.meta
# dup-ok: 两次整数除法是有意的 —— 第一次从"×100 的整数"回到原值, 第二次取 1%
scoreboard players operation #mz zx.meta /= #100 manacore.meta

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #mz zx.meta
function manacore:api/mana/add

# ============================================================
# sweetdream:equipment/armor/flesh_mill/gain —— 血肉磨坊: 加"本秒该回的魔力"
# ------------------------------------------------------------
# 【入参】#fm_add = 本秒该回多少(已由 passive 算好, >= 1)
# 【执行者】玩家    【前置】已跑过 lib/uuid(拿 zx:data self.uuid)
# 【为什么不直接写在 passive 里】api/mana/add 要写公共输入口 manacore:in arg,
#   单独拆出来, passive 里那条 `if ... run function` 一眼就能看出"只在需要时写"。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #fm_add zx.meta
function manacore:api/mana/add

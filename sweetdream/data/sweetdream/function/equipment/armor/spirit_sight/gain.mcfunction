# ============================================================
# sweetdream:equipment/armor/spirit_sight/gain —— 灵视: 自身回 1 点魔力
# ------------------------------------------------------------
# 【执行者】玩家    【入参】无
# 【为什么单独拆一份】api/mana/add 要写公共输入口 manacore:in arg,
#   单独放一份, passive 里那行 `function ... gain` 一眼就是"只在需要时写"。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ============================================================
# sweetdream:equipment/armor/tide_fold/ball_calc —— 算「最大魔力 ×0.02」
# ------------------------------------------------------------
# 【执行者】玩家(@s) —— 由 ball_bonus ③ 送进来
# 【出参】#tf_b zx.meta = 最大魔力 ×0.02 ×1000（毫魔力点的 2%）
# 【×1000 定点】max_mana ×1000 ÷ 50 = ×0.02 ×1000
#   ★ 别忘了 `data get … 1000` 的第三段是**乘数**不是精度(坑: 写 0.1 = 除十)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #tf_b zx.meta 0
execute if data storage manacore:out r.value store result score #tf_b zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #tf_b zx.meta /= #50 zx.meta

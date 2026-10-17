# ============================================================
# sweetdream:equipment/armor/candle_step/atk_back —— 残烛: 把那份 +10% 基础攻击力退回去
# ------------------------------------------------------------
# 【谁调用它】candle_step/second（到期 / 拆件那一刻）、candle_step/set_atk（叠加前先退旧的）
# 【执行者】玩家
# 【出参】无（副作用: 面板 base_attack 减回 + 账本归零）
# 【★ 只按**账本**减, 不读面板反推 ★】面板里混着别的装备的加成, 反推会算错
#   （同 charge/mode_off 的口径）。账本记的是"当时加了多少 ×100",
#   取负后 ×0.001 正好是"当时加的那个数"的相反数。
# 【★ 为什么末尾把 cs_end 也归零 ★】留着旧到期刻没有意义, 还会让 second 的
#   "到期判定"在下一轮误判(值已经退回去了, 却又触发一次 atk_back —— 虽然那时
#   账本是 0 会直接返回, 但白跑)。归零后状态干净。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ① 取负的账本值（×100 的整数）
scoreboard players set #csa_neg zx.meta 0
scoreboard players operation #csa_neg zx.meta -= @s zx.cs_batk

# ② 加回去（负值 = 减; ×0.001 把 ×100 的账本还原成原值再取负）
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #csa_neg zx.meta
function manacore:api/stats/add

# ③ 账本与到期刻归零
scoreboard players set @s zx.cs_batk 0
scoreboard players set @s zx.cs_end 0

# ============================================================
# sweetdream:equipment/sword/crescent/cast —— 缺月 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/crescent(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 240 / 冷却 30 秒。
#   "使用时，将当前快捷栏内所有技能的剩余冷却时间暂时冻结 6 秒。玩家每冻结 1 秒总
#    剩余冷却时间，本技能最终伤害就提高 1%（最高 +150%）。6 秒结束时，对 6 格内全部
#    目标造成相当于最大魔力 ×0.12 + 基础攻击力 ×4 的伤害，之后被冻结的技能继续正常冷却。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: 结束时对**自身 6 格内全部**目标。
#   ③ 次数: 伤害 1 次(6 秒后结算)。
#   ④ 时长: 冻结窗 6 秒(zx.cr_t = 120, 由 core/tick 每刻扣)。
# 【★ "冻结"怎么实现(不是"延后 6 秒"那么简单) ★】
#   真的冻结 = 窗内每刻把被冻结技能的剩余冷却**顶回原值**(api/cooldown/increase 1 tick),
#   于是屏幕上剩余秒数**原地不动**; 窗一过不再顶, 就继续正常倒计时。
#   ★ 反面做法(把 end 一次性 +120)在"什么时候能用"上等价, 但会让屏幕上的剩余**跳一下**
#     —— 与原文"暂时冻结"的观感不符, 所以没用它。
#   被冻结的名单在施法那一刻**拍快照**(zx:freeze p."<uuid>".s0..s8 = 各快捷栏格的 skill),
#   窗内不再看玩家手里拿着什么 ⇒ 换手/换位不影响(见 cap)。
# 【伤害加成】"每冻结 1 秒总剩余冷却 +1%" ⇒ 加成% = round(Σ剩余tick / 20), 上限 150。
# 【数值改哪】窗长 120 = 这里的 set 与 freeze_tick 的判据; 加成上限 150 = cap 末尾;
#   结算伤害 = freeze_end 的 max_mana_mul 0.12 / attack_mul 4.0; 范围 6 = freeze_end 的 distance=..6。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/crescent

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 只读检查: 冷却 + 魔力 240
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:crescent",mana:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"缺月冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ★ 这里**不**要求"附近有目标" —— 原文的收益主体是"冻结冷却", 没怪时也应当能放。

# ② 扣魔力 -240
data modify storage manacore:in arg set value {uuid:"",value:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ③ 记冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:crescent",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ④ 拍"被冻结名单"快照 + 算加成% (写进 @s zx.cr_b)
scoreboard players set #cr_tt zx.meta 0
data modify storage zx:work crd set value {uuid:""}
data modify storage zx:work crd.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/crescent/cap with storage zx:work crd

# ⑤ 开冻结窗 6 秒 = 120 tick(core/tick 每刻 -> freeze_drive -> freeze_tick)
scoreboard players set @s zx.cr_t 120

# ⑥ 反馈
tellraw @s [{"text":"缺月 · 冻结 ","color":"light_purple"},{"score":{"name":"@s","objective":"zx.cr_b"},"color":"aqua"},{"text":"% 的剩余冷却，伤害加成 ","color":"light_purple"},{"score":{"name":"@s","objective":"zx.cr_b"},"color":"red"},{"text":"%","color":"light_purple"}]
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.8 1.4
execute at @s run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.6 1.6

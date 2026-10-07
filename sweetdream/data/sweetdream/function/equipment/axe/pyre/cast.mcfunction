# ============================================================
# sweetdream:equipment/axe/pyre/cast —— 葬火 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/pyre(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 100%(放空当前魔力) / 冷却 240 秒。
#   "使用后下一次攻击额外对自身 2 格内的全部生物造成 X 点伤害并使其燃烧 X×0.05 秒。
#    2 秒后再对自身 5 格范围内的全部生物造成 X×0.5 点伤害。X 为使用技能所消耗的魔力。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键(只"挂上"状态, 不立刻打伤害)。
#   ② 目标范围: 下一次攻击时 —— 自身 2 格内全部; 2 秒后 —— 自身 5 格内全部。
#   ③ 次数: 攻击那一刻 1 次(2 格); 2 秒后 1 次(5 格)。
#   ④ 时长: "下一次攻击"= 一直挂着直到打出下一次攻击(玩家 2026-10-07 定: 不设时限);
#      2 秒 = 40 tick 倒计时(core/tick 推, 见 tick)。
# 【X 是变量】X = 本次放空的魔力总量。cast 记 zx.py_x = X, 并置 zx.py_rdy = 1("下一次攻击已就绪")。
#   攻击时在 hit 里消费; 2 秒后的那一发由 boom 用同一个 X 结算。
# 【观测镜】zx.py_x 已登记为层数行 —— 挂着 X 时面板会显示「葬火 X」, 打完清 0。
# 【数值改哪】伤害值 = X 原样; 燃烧 = X×0.05 秒 = **X tick**(×20÷1000→见 hit); 延迟 = tick 的 40。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/pyre

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 只看冷却(魔力是"放空", 不作下限要求)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:pyre",mana:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"葬火冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 读当前魔力 = X(放空总量), 然后全部消耗
data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #py_x zx.meta 0
execute store result score #py_x zx.meta run data get storage manacore:out r.value

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #py_x zx.meta
function manacore:api/mana/consume

# ④ 起冷却 240 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:pyre",cooldown_seconds:240.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 存 X + 置"下一次攻击已就绪"; 顺手清掉上一轮可能残留的延迟倒计时
scoreboard players operation @s zx.py_x = #py_x zx.meta
scoreboard players set @s zx.py_rdy 1
scoreboard players set @s zx.py_d 0

# ⑥ 表现
execute at @s run particle minecraft:flame ~ ~1 ~ 0.5 0.5 0.5 0.03 18 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 0.8
tellraw @s [{"text":"葬火: 已放空 ","color":"dark_red"},{"score":{"name":"#py_x","objective":"zx.meta"},"color":"red"},{"text":" 点魔力, 下次攻击将引爆","color":"dark_red"}]

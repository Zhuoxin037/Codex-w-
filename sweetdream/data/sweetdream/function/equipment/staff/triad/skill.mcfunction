# ============================================================
# sweetdream:equipment/staff/triad/skill —— 很冰的斧: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 500 魔力 / 冷却 80 秒。使用后若**再次使用**该技能则切换武器至下一把。
#   使用后召唤一个术阵。武器被动强化(持续 15 秒):
#     冰斧 概率 20%→60%, 伤害改 最大魔力 ×0.05
#     热刀 概率 40%→100%, 每次 -1 护甲, 命中 3 次后 -1 护甲韧性(结束后恢复)
#     重枪 下次不再为空, 且每次使目标抗性提升失效 2 秒
#   强化结束后切回「很冰的斧」。
# 【★ 为什么"再按一次"不扣蓝也不进冷却 ★】文案说"使用后若再次使用该技能则切换",
#   而技能本身有 80 秒冷却 —— 真等冷却好了再按, 强化早就结束了(15 秒)。
#   所以"再按一次"指的是**强化期间**再按: 那时只做形态切换, 不重复扣蓝/进冷却。
#   (若也扣 500 蓝, 玩家练级时会因为一次误触直接空蓝。)
# 【形态存在玩家身上】见 attack 的说明 —— 不写进物品 NBT(快照会分叉)。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/triad

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 强化期间再按 ⇒ 只切形态, 直接收工(不扣蓝 / 不进冷却)
execute if score @s zx.tri_strong matches 1.. run function sweetdream:equipment/staff/triad/next_form
execute if score @s zx.tri_strong matches 1.. run return 0

# ③ 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:triad",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"很冰的斧冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 500）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 500）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 80 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:triad",cooldown_seconds:80.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 术阵 + 开强化 15 秒
function sweetdream:equipment/staff/triad/start

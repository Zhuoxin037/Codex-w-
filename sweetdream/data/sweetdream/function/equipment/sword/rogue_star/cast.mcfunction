# ============================================================
# sweetdream:equipment/sword/rogue_star/cast —— 游星 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/rogue_star(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 200 / 冷却 30 秒。
#   "锁定自身 10 格范围内的 3 个生物，3 秒后对其 2 格内的全部生物造成相当于
#    自身基础攻击力 ×4 的伤害。（保底 12 点伤害）"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键(消耗物品)。
#   ② 目标范围: 锁定"自身 10 格范围内的 **3 个**生物" -> sort=nearest,limit=3;
#      结算时对"被锁生物 **2 格内的全部生物**"(AOE)。
#   ③ 次数: 一次施法锁定一次、3 秒后各结算一次。
#   ④ 时长: **3 秒**后结算(60 tick) —— 用"每人自己的到点时刻"存施法者记录里,
#      由 lib/second 每秒扫(和流光同一套, 不用 schedule, 多人同时放不会互顶)。
# 【伤害】基础攻击力 ×4 -> 走 attack_mul 通道; 保底 12(算完抬一手)。
# 【为什么要宏】锁定标签名里带施法者自己的 UUID(zx.rs_<uuid>), 只能宏拼。
#   本函数只负责"校验 -> 扣蓝 -> 冷切 -> 算伤害 -> 交给 lock"; 锁定/记账/结算
#   全在 lock / hit_due / aoe 三层里。
# 【数值改哪】距离 10 = ③ 与 lock 的选择器; 目标数 3 = lock 的 limit;
#   延迟 3 秒 = lock 的 +60; 倍率 4 = 下面的 attack_mul; 保底 12 = 下面的 12.0;
#   结算半径 2 = aoe 的 distance=..2。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话这个进度一辈子只触发一次)
advancement revoke @s only sweetdream:equipment/sword/rogue_star

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①b 【超限】手里这把是不是超限版(决定"锁定几个 / 打几次 / 保底多少")
#   基础版: 锁定 3 个 · 打 1 次 · 保底 12
#   超限版: 锁定**全部** · 打**两次** · 保底 16(见下面 ⑥ 和 lock / aoe)
function sweetdream:equipment/sword/rogue_star/is_ol

# ② 只读检查: 冷却好没好 + 魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:rogue_star",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"游星冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 10 格内一个都没有就整个不放(不扣蓝、不进冷却)
#   distance=0.1..10 的下界把自己排除掉(自己到自己是 0 格)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10] run return fail

# ④ 扣魔力 -200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:rogue_star",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 算伤害: 基础攻击力 ×4(基础和超限同倍率, 变的是"打几次")
data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
#   保底: 基础版 12 / 超限版 16(算完抬一手, 写在 out 上, 后面宏层直接读它)
execute store result score #dmg zx.meta run data get storage manacore:out r.damage 1
execute unless score #rs_ol zx.meta matches 1 if score #dmg zx.meta matches ..11 run data modify storage manacore:out r.damage set value 12.0
execute if score #rs_ol zx.meta matches 1 if score #dmg zx.meta matches ..15 run data modify storage manacore:out r.damage set value 16.0

# ⑦ 锁定 + 记账 + 表现(全在宏层, 因为标记名字里要带自己的 UUID)
#    ol 一并带下去: lock 靠它定"锁几个", 并记进 zx:data rs.<uuid>.ol
#    供 3 秒后的 hit_due 决定"打一次还是两次"。
data modify storage zx:work a set value {uuid:"",damage:0.0,ol:0b}
data modify storage zx:work a.uuid set from storage zx:data self.uuid
data modify storage zx:work a.damage set from storage manacore:out r.damage
execute if score #rs_ol zx.meta matches 1 run data modify storage zx:work a.ol set value 1b
function sweetdream:equipment/sword/rogue_star/lock with storage zx:work a

# 宏层没锁定成功(理论上不会, ③ 已经拦过一次)就到此为止
execute unless data storage zx:work a{locked:1b} run return fail

# ⑧ 打上"我有一笔延迟结算待处理", 3 秒后由 lib/second 扫到点结算
tag @s add zx.rs_casting

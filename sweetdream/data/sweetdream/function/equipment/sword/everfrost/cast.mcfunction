# ============================================================
# sweetdream:equipment/sword/everfrost/cast —— 永霜 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/everfrost(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 200 / 冷却 30 秒。
#   "冰冻自身 5 格范围内的 8 个生物 3 秒，并在结束后对被冰冻的生物造成相当于
#    自身**当前剩余魔力值** ×0.1 的伤害。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键(消耗物品)。
#   ② 目标范围: "自身 5 格范围内的 **8 个**生物"(sort=nearest,limit=8)。
#   ③ 次数: 一次施法冻一批、3 秒后对被冻住的这批各结算一次。
#   ④ 时长: **3 秒**(60 tick) —— 到点时刻存施法者记录, core/tick 每刻判(不用 schedule)。
# 【★ 伤害基数是"当前剩余魔力值", 不是上限 ★】-> 走 other_mul 通道(基数默认当前魔力),
#   而且要在**结算那一刻**才算(施法后可能已经回魔/被扣蓝, 用当时的当前魔力)。
# 【冻结怎么做到】lib/freeze: 写 TicksFrozen(原版结霜外观) + 移动速度乘区 -100%
#   (走不动, 但还能转身/攻击)。3 秒 = 60 tick, 解冻由 lib/unfreeze_sweep 每秒扫。
# 【数值改哪】距离 5 / 目标数 8 = lock 的选择器; 延迟 3 秒 = lock 的 +60 与 freeze 的 ticks;
#   倍率 0.1 = hit_due 的 other_mul。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/everfrost

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 ★ 超限快照 ★ 结算是 3 秒后(超限还要再拖 10 秒)才发生的, 那时手里可能已经
#      换掉了 —— 所以在这里把"敲没敲超限"拍下来, 一路写进结算记录。
#      【超限·永霜 加在这把上的机制(逐字照抄 oldef."everfrost".lore)】
#        冰冻自身 5 格范围内的**全部**生物 3 秒(基础版是 8 个),
#        之后每秒对被冰冻的生物造成一次相当于**其最大生命值 ×0.03**的真实伤害
#        (最多 10 秒), 并在结束后对被冰冻的生物造成相当于自身当前魔力值
#        ×0.15 的伤害(基础版 ×0.1)。
#      【★ 时间线(用户 2026-10-08 口径, 实现见 pulse_ol)★】
#        施法 -> 冻 3 秒(lib/freeze) **同时**开始持续伤害计时:
#        · 第 1/2/3… 秒: 对"此刻**仍然被冻着**"的目标各打一次 最大生命 ×0.03
#        · 别的武器续冻 -> 目标的 zx.fz_end 往后推 -> 伤害跟着延长
#        · 某只解冻的那一刻 -> **只对它**结算一次 当前魔力 ×0.15(逐目标, 见 finish_one)
#        · 到 10 秒硬上限 -> 剩下没结束的全部结算(见 finish_ol)
function sweetdream:equipment/sword/everfrost/is_ol

# ② 只读检查: 冷却好没好 + 魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:everfrost",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"永霜冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 5 格内一个都没有就整个不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..5] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..5] run return fail

# ④ 扣魔力 -200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:everfrost",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 冻住 8 个 + 记账 + 表现(宏层, 因为标记名要带自己的 UUID)
data modify storage zx:work a set value {uuid:"",ol:0b}
data modify storage zx:work a.uuid set from storage zx:data self.uuid
execute if score #ef_ol zx.meta matches 1 run data modify storage zx:work a.ol set value 1b
function sweetdream:equipment/sword/everfrost/lock with storage zx:work a

# 宏层没冻到(理论上不会, ③ 已拦过)就到此为止
execute unless data storage zx:work a{locked:1b} run return fail

# ⑦ 打上"我有一笔延迟结算待处理", 3 秒后由 lib/second 扫到点结算
tag @s add zx.ef_casting

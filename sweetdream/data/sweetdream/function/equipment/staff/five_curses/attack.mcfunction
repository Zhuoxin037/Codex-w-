# ============================================================
# sweetdream:equipment/staff/five_curses/attack —— 五世恶咒: 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】消耗 100 魔力; 伤害 = 自身**当前**魔力值 ×0.03。
#   每次普攻命中后都会向目标施加一层「世咒」(第一~五世)。
# 【伤害通道】走 calc 的 **other** 通道: other_base = -1(默认) = 玩家**当前**魔力,
#   other_mul = 0.03 ⇒ 正好是文案的"当前魔力 ×0.03", 不必自己拼定点乘法。
#   ★ 与堕梦不同: 堕梦是 max_mana_mul(最大魔力), 本件是**当前**魔力 —— 别照抄错。
# 【伤害谁来打】法球自己打(ball/hit 第 ④ 步会按 data.dmg 结算), 所以这里把算好的
#   伤害直接塞进 ball.dmg; 命中回调 ball_hit 只负责**叠世咒**, 不再重复打伤害。
#   (堕梦要把普通伤害改成真伤, 才不得不把 dmg 设 0、另存 fdmg 在回调里分流。
#    本件没有"改伤害类型"的需求, 走最普通的那条路。)
# 【外观】style 留空 => 发射器会补成 "plain"(fx_plain / fx_plain_hit 已存在)。
#   专属外观(批 12 外观批次)再补 fx_five_curses + 在 ball/tick、ball/hit 各加一行分支。
# ============================================================

# ① 拿 uuid
# ★ 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)。
#   ★ 必须排在**扣魔力之前**: 拦晚了就成了"扣了蓝但没出手"。
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 100(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fcv_attack",mana:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #fcv_need zx.meta 0
execute store result score #fcv_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#fcv_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 算伤害: 当前魔力 ×0.03(超限的伤害乘区在 calc 前由 mod 乘进通道)
#   ★ 2026-10-13 用户拍板: **先算伤害、后扣魔力** ⇒ 用的是**扣费前**的魔力。
#     旧版先 consume 再 calc ⇒ 读到的是扣掉 100 之后的魔力: 满魔 1000 时文案给人的
#     预期是 1000×0.03=30, 实际只有 900×0.03=27。文案写"自身**当前**魔力值 ×0.03",
#     玩家按下右键那一刻面板上显示的就是扣费前的数 ⇒ 按扣前值算才对得上体感。
#   ★ 顺序安全: 下面的 consume 只写 r.success / r.reason 两个键(不是整体替换
#     manacore:out r), 不会把这里算好的 r.damage 冲掉 —— 可以放心把它排在扣费前。
data modify storage manacore:in arg set value {uuid:"",other_mul:0.03,other_base:-1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ④ 扣魔力 100(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#fcv_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 装球出膛: 伤害交给法球, 命中回调只叠世咒
data modify storage zx:work ball set value {dmg:0.0,hit:"sweetdream:equipment/staff/five_curses/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack

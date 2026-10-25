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
# 【外观】style:"five_curses" —— 专属拖尾/命中已补(2026-10-13): fx_five_curses /
#   fx_five_curses_hit, 由 .workbuddy/_gen_staff_particles.py 生成, 派发在 ball/tick ④
#   与 ball/hit ⑤。漏了 style 会兜底成 fx_plain(白球), 与别的法杖长得一样。
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

# ①.5 超限判定(批 K9): 主/副手任一件是超限·五世恶咒 ⇒ 普攻 100→**150**
scoreboard players set #fcv_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["five_curses"],ol:"five_curses"}] run scoreboard players set #fcv_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["five_curses"],ol:"five_curses"}] run scoreboard players set #fcv_ol zx.meta 1

# ② 只读检查: 魔力 100(超限 150; 普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fcv_attack",mana:100.0}
execute if score #fcv_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 150.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #fcv_need zx.meta 0
execute store result score #fcv_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#fcv_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 100(超限 150) —— 用 olv.mana(mod 已算过的值), 与上面的检查同源
data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#fcv_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 当前魔力 ×0.03(超限的伤害乘区在 calc 前由 mod 乘进通道)
#   ★ 2026-10-13 拍板: **跟随全仓惯例 = 先扣魔力、后算伤害**(读到的是扣费**后**的魔力)。
#     同口径的先例全部是"先扣后算", 共 8 处 —— 本件不是孤例, 别再单独改它:
#       海棠 begonia/attack(30) · 蛊毒 gu_poison/attack(80) ·
#       风止之地 wind_ontheground/attack · 灰度 grayscale/cast ·
#       万相 myriad/cast · 负离子斧 anion/cast · 解梦师 dream_reader/cast ·
#       永霜 everfrost/cast(扣 200, 冰冻结束时才结算 —— 同样用的扣后魔力)。
#     ⇒ 满魔 1000 时本件是 (1000-100)×0.03 = 27, 与海棠/蛊毒等完全一致。
#   ⚠️ 想改成"先算后扣"会让它成为全仓唯一例外 —— 守门 `manafirst` 会拦下。
data modify storage manacore:in arg set value {uuid:"",other_mul:0.03,other_base:-1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球出膛: 伤害交给法球, 命中回调只叠世咒
#   ★ 把"这一发是不是超限版"塞进球的 data(ol), 让 ball_hit 那一侧也能分档 ——
#     命中回调是**以法球为执行者**跑的, 那时拿不到玩家, 读不了 SelectedItem。
data modify storage zx:work ball set value {dmg:0.0,style:"five_curses",hit:"sweetdream:equipment/staff/five_curses/ball_hit",ol:0b}
execute if score #fcv_ol zx.meta matches 1 run data modify storage zx:work ball.ol set value 1b
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack

# 用户授权的猴头模型动效；不改变上述原技能的数值与执行顺序。
function sweetdream:equipment/staff/five_curses/visual/begin_attack

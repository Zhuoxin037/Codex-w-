# ============================================================
# sweetdream:equipment/sword/deepsea_echo/cast —— 深海的回响: 起链
# ------------------------------------------------------------
# 【文案】消耗 350 魔力 / 冷却 30 秒。
#   标记 12 格内离自身最近的一个生物并使其附加「渊海」;
#   1 秒后对其 3 格范围内的全部生物造成 当前魔力 ×0.15 的伤害,
#   之后标记受到伤害的生物并重复, 每次重复再花 110 魔力, 重复 2 次后结束。
#
# 【整体结构】这不是一次结算, 而是"一波 → 1 秒 → 下一波"的连锁:
#   cast  →  seed (挑最近的 + 上渊海 + 记状态)  →  schedule 1s
#   wave  →  逐玩家 → wave_go (算伤害 · 每个源各结算一次 · 把受害者变成下一波的源)
#                 →  还有次数就再花 110 魔力, 1 秒后下一波; 否则 finish
#
# 【几处关键设计】
#   · 每波的"源"用带自己 UUID 的标签 zx.de_<uuid> 打在生物身上 ——
#     和流光一个套路: 两个人同时放也不会互相串。
#   · 一句话里"谁被打到"要跨多个源累计, 所以用两层临时标签:
#     zx.de_hit = 当前这个源的受害者(每个源算完就清), zx.de_all = 本波累计。
#     不然第二个源会把第一个源打过的再打一遍。
#   · 每波的伤害只算一次(算进 manacore:out r.damage), 各个源直接读它,
#     省得把数值一路当宏参数传下去。
#   · 波数用 zx:data de."<uuid>".left 记, 现在写死 2(= 文案里"重复 2 次")。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/deepsea_echo

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①b 【超限】手里这把是不是超限版 —— 决定 范围(3/4 格) · 倍率(×0.15/×0.18) ·
#     重复耗蓝(110/80) · 有没有「渊海」免费再重复。
#     存进 zx:work de.ol 给 seed 抄进这次连锁的记录里(后面的文件都不是宏,
#     只能读 zx:work de.ol 这个共享节点, 见 wave_go ①b)。
#     ★ 和 passive 那条"物品栏里给水下呼吸"分开: 那是一条**被动**, 判的是背包;
#       这里判的是"手上拿着哪一把" —— 手上基础版 + 背包里躺着超限版时,
#       被动照常生效, 但技能按基础版结算。
function sweetdream:equipment/sword/deepsea_echo/is_ol
data modify storage zx:work de set value {uuid:"",ol:0b}
execute if score #de_ol zx.meta matches 1 run data modify storage zx:work de.ol set value 1b

# ② 只读检查: 冷却 + 魔力 350
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:deepsea_echo",mana:350.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"深海的回响冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 350)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 12 格内得有目标, 没有就整个不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..12] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..12] run return fail

# ④ 扣魔力
#   【三个数字必须一致】上面 ② 里 api/skill/check 的 mana:、
#   这里 value:、以及 give 描述里的"魔力 X" —— 三处要一起改。
data modify storage manacore:in arg set value {uuid:"",value:350.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
# 【这条提示千万别删】检查用的数字和这里扣的数字如果对不上, 就会"检查通过、扣不动";
#   而扣不动时如果一声不吭, 表现就是"右键毫无反应", 极难查。
#   (踩过一次: 检查写 10、扣写 350, 结果什么都没发生。)
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足, 扣不动(需要 350)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却(观测镜会自动显示)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:deepsea_echo",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 挑目标 + 上「渊海」+ 记状态(宏层, 因为标记名里要带自己的 UUID)
data modify storage zx:work de.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/deepsea_echo/seed with storage zx:work de

# ⑦ 起链: 1 秒后第一波
#   【★ 为什么不用 schedule ★】schedule 是按**函数名**排队的, 而且默认是 replace
#     模式 —— 谁再排一次同名函数, 就把上一条顶掉。这里的后果是:
#       · 两个人几乎同时放深海 -> 后放的人把先放的人那一波顶了, 水链少打一波;
#       · 同一个人"上一波还没到、又开了一条新链"(理论上冷却内不会, 但改数值后就可能)
#         -> 两条链并成一条, 时间点漂移。
#     所以改成"每人身上一个倒计时 zx.de_t", 由 core/tick 每刻推 ——
#     多人同时施法各走各的, 谁也不影响谁。
#   【为什么是 20】core/tick 里是"先减 1 再判 <=0", 所以设 20 = 正好 20 tick
#     后推进, 和原来的 schedule ... 1s 等价。
tag @s add zx.de_run
scoreboard players set @s zx.de_t 20

# ⑧ 播放连续水刃释放动画(48 tick = 2.4 秒)
#   【为什么放最后】前面 ①-⑥ 任何一步 return fail, 技能就没有成立, 不该有动画。
#   【为什么和时间轴对得上】动画从这一刻起算, 第 20 tick 正好是技能第一波水链
#     落地(1 秒 = 20 tick), anim/fx 在那一帧单独加了一圈最亮的环 ——
#     于是原有水花粒子和"水链打到人"仍在同一条时间轴上。
#   【它自己会收尾】anim/end 摘 tag; 中途把剑丢了也不会卡住(见 anim/end 注释)。
function sweetdream:equipment/sword/deepsea_echo/anim/start

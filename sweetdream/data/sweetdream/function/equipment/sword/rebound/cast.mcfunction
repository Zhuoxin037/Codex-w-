# ============================================================
# sweetdream:equipment/sword/rebound/cast —— 回锋 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/rebound(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 80 / 冷却 12 秒。（超限不改魔力与冷却）
#   未超限: "对自身前方 3×5 格内的生物造成相当于自身基础攻击力 ×2 的伤害。若有「断刃」则
#    消耗全部「断刃」且每有一层则重复一次以上效果。"
#   超限·回锋(2026-10-23 批 K2): 同上, 但**每重复一次还让"当次"的倍率翻倍一次**
#    ⇒ 打击次数 1+层数 不变; ★ 2026-10-23 用户纠正: 是**每段递增**, 不是整轮统一翻倍:
#      第 1 段 ×2, 第 2 段 ×4, 第 3 段 ×8, 第 4 段 ×16, 第 5 段 ×32(4 层时)。
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: "自身**前方** 3 格宽 × 5 格长" -> 用 3 个采样点(前向 1.0/2.5/4.0 格,
#      各半径 1.5)合出一条 3×5 走廊(见 strike)。
#   ③ 次数: 基础 1 次(当场打) + 「断刃」每一层**再重复一次**(总次数 = 1 + 层数, 上限 4)。
#      ★★ 2026-10-07 用户改口径: **不再同刻一次性打完** —— 第 1 次当场打,
#         之后**每 0.5 秒(10 刻)重复一次**, 由 core/tick 驱动 tick_step(见那两个文件的头注释)。
#   ④ 时长: 起手即打; 每多一层再等 0.5 秒(3 层 ≈ 1.05 秒打完)。「断刃」施法后全部清空。
# 【伤害】基础攻击力 ×2 -> attack_mul 通道; **每次打击前由 recalc 重算**(zx:work rba 是共享
#   节点, 不能跨刻留着, 否则两个玩家先后施法会互顶)。
# 【数值改哪】倍率 2 = recalc 的 attack_mul; 间隔 = tick_step 的 `set @s zx.rb_t 10`(10 刻 = 0.5 秒)
#   与 core/tick 的筛选 `zx.rb_t=1..`; 采样点/半径 = strike 与 area; 层数上限 = hit 的 matches 3..。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/rebound

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 80
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:rebound",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"回锋冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 80）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 前方有目标吗? 没有就整个不放(不扣蓝、不进冷却)
#   rotated ~ 0 = 朝向保留、俯仰归零; positioned ^ ^ ^2.5 = 前方 2.5 格处为圆心
execute rotated ~ 0 positioned ^ ^ ^2.5 unless entity @e[type=!#sweetdream:no_damage,distance=..2.5] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute rotated ~ 0 positioned ^ ^ ^2.5 unless entity @e[type=!#sweetdream:no_damage,distance=..2.5] run return fail

# ④ 扣魔力 -80
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 12 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:rebound",cooldown_seconds:12.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤' 到这里才算"这一发真的放出去了", 现在才清上一轮的连击残值(正常 1 秒内打完;
#   防退游戏/被打断留下残值)。
#   ★★ 2026-10-10 修 F11: 原来这三行在**最前面**(校验之前) ★★
#     于是"冷却中再右键"这种**注定失败**的尝试, 也会先把上一轮**还没打完**的
#     连击队列(rb_t / rb_rep)清掉 —— 白丢后面几段。校验失败必须无副作用,
#     所以搬到这里: 扣完蓝、记完冷却 = 确定要放, 才允许覆盖旧队列。
scoreboard players reset @s zx.rb_t
scoreboard players reset @s zx.rb_rep

# ⑤'' 超限口径(2026-10-23 批 K2; ★ 同日用户纠正: **每段递增**, 不是整轮统一翻倍)
#   "若有「断刃」则消耗全部「断刃」且每有一层则重复一次以上效果**且该技能倍率翻倍一次**"
#   ⇒ 打击次数不变(1 + 层数, 仍由 ⑦/⑦' 按 0.5 秒一段放电);
#     **第 1 段倍率恒 ×2**(与未超限一致), 之后**每重复一次, 那一段的倍率 ×2**:
#       层数 0: ×2                        层数 1: ×2, ×4
#       层数 2: ×2, ×4, ×8                层数 3: ×2, ×4, ×8, ×16
#       层数 4: ×2, ×4, ×8, ×16, ×32
#   实现: 倍率是**千分比整数**(2000 = ×2, 计分项存不了小数), 起手 2000;
#         tick_step 在每段打之前 `×= #2`(只在超限时) —— 因为连击跨刻, 那一段打的时候
#         手上的剑未必还是回锋 ⇒ 超限与否在**起手这一刻**拍进 zx.rb_ol(玩家级), 不在中途重判。
scoreboard players set #rb_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["rebound"],ol:"rebound"}] run scoreboard players set #rb_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["rebound"],ol:"rebound"}] run scoreboard players set #rb_ol zx.meta 1

scoreboard players set @s zx.rb_ol 0
execute if score #rb_ol zx.meta matches 1 run scoreboard players set @s zx.rb_ol 1
scoreboard players set @s zx.rb_omul 2000

# ⑥ 算伤害: 基础攻击力 ×2 (写进 zx:work rba.damage, 就是下面 strike 的宏参数)
function sweetdream:equipment/sword/rebound/recalc

# ⑦ 立刻打第一次"前方 3×5"
function sweetdream:equipment/sword/rebound/strike with storage zx:work rba

# ⑦' ★ 有「断刃」-> 排"每 0.5 秒(10 刻)再重复一次"(2026-10-07 用户口径:
#     不再是同刻一次性打完, 而是每隔 0.5 秒打一次)
#     zx.rb_rep = 还要重复几次(就是层数, 上限 3); zx.rb_t = 上弦 10 刻, 由 core/tick 驱动
scoreboard players operation @s zx.rb_rep = @s zx.rb_blade
execute if score @s zx.rb_rep matches 1.. run scoreboard players set @s zx.rb_t 10

# ⑧ 消耗全部「断刃」
scoreboard players set @s zx.rb_blade 0

# ⑨ 表现: 一击破风
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.9 1.1

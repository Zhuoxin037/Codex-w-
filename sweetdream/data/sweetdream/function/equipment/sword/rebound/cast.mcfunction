# ============================================================
# sweetdream:equipment/sword/rebound/cast —— 回锋 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/rebound(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 80 / 冷却 12 秒。
#   "对自身前方 3×5 格内的生物造成相当于自身基础攻击力 ×2 的伤害。若有「断刃」则
#    消耗全部「断刃」且每有一层则重复一次以上效果。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: "自身**前方** 3 格宽 × 5 格长" -> 用 3 个采样点(前向 1.0/2.5/4.0 格,
#      各半径 1.5)合出一条 3×5 走廊(见 strike)。
#   ③ 次数: 基础 1 次(当场打) + 「断刃」每一层**再重复一次**(总次数 = 1 + 层数, 上限 4)。
#      ★★ 2026-10-07 用户改口径: **不再同刻一次性打完** —— 第 1 次当场打,
#         之后**每 0.35 秒(7 刻)重复一次**, 由 core/tick 驱动 tick_step(见那两个文件的头注释)。
#   ④ 时长: 起手即打; 每多一层再等 0.35 秒(3 层 ≈ 1.05 秒打完)。「断刃」施法后全部清空。
# 【伤害】基础攻击力 ×2 -> attack_mul 通道; **每次打击前由 recalc 重算**(zx:work rba 是共享
#   节点, 不能跨刻留着, 否则两个玩家先后施法会互顶)。
# 【数值改哪】倍率 2 = recalc 的 attack_mul; 间隔 = tick_step 的 `set @s zx.rb_t 7`(7 刻 = 0.35 秒)
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
function manacore:api/mana/consume
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

# ⑥ 算伤害: 基础攻击力 ×2 (写进 zx:work rba.damage, 就是下面 strike 的宏参数)
function sweetdream:equipment/sword/rebound/recalc

# ⑦ 立刻打第一次"前方 3×5"
function sweetdream:equipment/sword/rebound/strike with storage zx:work rba

# ⑦' ★ 有「断刃」-> 排"每 0.35 秒(7 刻)再重复一次"(2026-10-07 用户口径:
#     不再是同刻一次性打完, 而是每隔 0.35 秒打一次)
#     zx.rb_rep = 还要重复几次(就是层数, 上限 3); zx.rb_t = 上弦 7 刻, 由 core/tick 驱动
scoreboard players operation @s zx.rb_rep = @s zx.rb_blade
execute if score @s zx.rb_rep matches 1.. run scoreboard players set @s zx.rb_t 7

# ⑧ 消耗全部「断刃」
scoreboard players set @s zx.rb_blade 0

# ⑨ 表现: 一击破风
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.9 1.1

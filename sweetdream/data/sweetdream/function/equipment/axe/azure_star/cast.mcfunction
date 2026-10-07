# ============================================================
# sweetdream:equipment/axe/azure_star/cast —— 苍蓝星 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/azure_star(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 500 / 冷却 80 秒。
#   "使用后对离自身最近的一个生物造成相当于自身最大魔力值 ×0.5 的伤害，之后对其 2 格内
#    的生物造成相当于自身最大魔力值 ×0.1 的伤害。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: 第一段 = 离自身**最近的一个**生物(就近取 1 只, 8 格内 —— 文案没给
#      距离, 按全包"最近的一个生物"惯例 8 格, 见 苦痛/惑梦); 第二段 = **那一只** 2 格内的
#      **全部**生物。
#   ③ 次数: 两段各 1 次。
#   ④ 时长: 起手即打第 1 段; 第 2 段隔 **0.35 秒(7 刻)** 落地(2026-10-07 用户口径:
#      "多段都依次隔 0.35 秒" —— 同刻两段会被受伤无敌帧吃掉一段)。见 dmg/dmg2/tick_step。
# 【★ 第二段的圆心是"被击中的那一只", 不是自己 ★】文案写"之后对**其** 2 格内的生物"
#   -> 锚点是那只生物身上的 zx.as_t 标签, 段② `execute at @e[tag=zx.as_t,limit=1]`。
# 【通道】两段都以**最大魔力值**结算 -> max_mana_mul。
# 【★ 被动翻倍(使用后消除) ★】hit 攒下的 zx.as_x2 = 1 时, "本武器伤害倍率翻倍":
#   recalc 里先把 zx.as_x2 读走并清零, 再把 max_mana_mul ×2(见 double),
#   并把"这次该翻倍"记进玩家计分项 zx.as_db —— 段② 晚 0.35 秒结算, 靠这份存根照样 ×2。
#   —— 玩家 2026-10-07 定稿: "增加至技能倍率上, 而使用后消除"。
# 【数值改哪】倍率 0.5 = recalc; 0.1 = recalc2; "最近"的范围 = dmg 的选择器;
#   2 格 = dmg2 的选择器; 间隔 = dmg 的 `set @s zx.as_d 7`(7 刻 = 0.35 秒)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/azure_star

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:azure_star",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"苍蓝星冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 500）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 8 格内至少有一个生物, 否则整个不放(不扣蓝、不进冷却) —— 不然 500 点白烧
execute at @s unless entity @e[type=!#sweetdream:no_damage,distance=0..8] run tellraw @s [{"text":"8 格内没有生物","color":"red"}]
execute at @s unless entity @e[type=!#sweetdream:no_damage,distance=0..8] run return fail

# ④ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 500）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 80 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:azure_star",cooldown_seconds:80.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 清掉上一轮可能残留的"第 2 段"状态(正常 0.35 秒内就落地了; 防退游戏/被打断留下残值)
scoreboard players reset @s zx.as_d
scoreboard players reset @s zx.as_db

# ⑦ 结算第 1 段(最近一只 ×0.5)
#    ★ 只打第 1 段: dmg 里会消费"被动翻倍"、留下存根 zx.as_db, 并给玩家排 zx.as_d = 7;
#      第 2 段(以其 2 格内全部生物 ×0.1)由 core/tick 到点驱动 tick_step -> dmg2。
function sweetdream:equipment/axe/azure_star/dmg

# ⑧ 表现
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.8 0.8 0.8 0.06 30 normal
execute at @s run particle minecraft:dust{color:[0.2,0.5,1.0],scale:1.4} ~ ~1 ~ 1.0 0.8 1.0 0.05 24 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 1.0 1.1

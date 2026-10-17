# ============================================================
# sweetdream:equipment/sword/blind_candle/cast —— 盲烛 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/blind_candle(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   ✦ 主动技能   魔力 200 · 冷却 30 秒
#   "使用后对前方 4×5 格范围内的全部生物造成一次相当于自身最大魔力值 ×0.14 的伤害。
#    若命中了附有「夜火」的生物，则消耗其中最近一个生物的「夜火」，并使自身获得
#    「烛火」，持续 8 秒。"
#   ✦ 烛火(不是独立技能, 是主动给的 8 秒状态)
#   "每次普通攻击后对目标 3 格内随机一个其他生物造成一次相当于自身最大魔力值 ×0.08
#    的伤害。若没有其他生物，则改为对被攻击的生物造成一次相当于自身最大魔力值 ×0.04
#    的伤害。"
# 【★ 四要素 ★】
#   ① 触发: 右键(主动) / 平A命中(被动与烛火, 见 hit 链)。
#   ② 范围: 主动"前方 4×5" -> area 的**两段采样球**(宽 4 / 深 5, 完全跟随朝向);
#      被动"其 2.5 格内随机一个其他生物"; 烛火"目标 3 格内随机一个其他生物"。
#   ③ 次数: 主动一段; 被动 5 秒最多一次(记在**玩家**身上 —— 原文是"该效果 5 秒内
#      最多触发一次", 不是"对同一个生物", 所以不能记在怪身上);
#      烛火没有节流, 8 秒内每一下平A都触发。
#   ④ 时长: 烛火 8 秒 —— 记成**绝对到期刻** zx.bcd_cd(> #now 就是还亮着),
#      不需要 lib/second 每秒递减, 也没有 marker。
# 【★ 通道 ★】主动 最大魔力×0.14 / 被动 ×0.06 或 ×0.1 / 烛火 ×0.08 或 ×0.04
#   —— 全是 mm ⇒ lib/skill_mul/def 里必须登记 wchan.blind_candle = {mm:1b,...}。
# 【数值改哪】200/30 = ②/⑤; 0.14 = ⑥; 4×5 = area 的两个球心与半径;
#   5 秒 = passive_gate 的 100; 8 秒 = dom_one ④ 的 160; 0.06/0.1 = hit_go ③;
#   2.5 格 / 3 格 = hit_go 的选择器; 0.08/0.04 = candle 的 calc。
# ============================================================

# ⓪ 撤销自己的进度(自撤销型进度首行必须 revoke)
advancement revoke @s only sweetdream:equipment/sword/blind_candle

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:blind_candle",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"盲烛冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 前方有没有目标? 一个都没有就整个不放
execute rotated ~ 0 positioned ^ ^ ^2.5 unless entity @e[type=!#sweetdream:no_damage,distance=..2.0] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute rotated ~ 0 positioned ^ ^ ^2.5 unless entity @e[type=!#sweetdream:no_damage,distance=..2.0] run return fail

# ④ 扣魔力 -200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:blind_candle",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 范围伤害 = 自身最大魔力值 ×0.14
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.14,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work bcd.dmg set from storage manacore:out r.damage

# ⑦ 框"前方 4×5" + 打范围伤害(命中者钉成 zx.bcd_hit)
function sweetdream:equipment/sword/blind_candle/area

# ⑧ 从命中者里挑**最近的一个**带「夜火」的
#   ★ 原文"消耗其中最近一个生物的「夜火」" —— 明写"最近一个", 只取 1 只。
tag @e[tag=zx.bcd_src,distance=0..] remove zx.bcd_src
execute as @e[type=!#sweetdream:no_damage,tag=zx.bcd_hit,distance=0..,tag=zx.status.yehuo,sort=nearest,limit=1] run tag @s add zx.bcd_src
execute if entity @e[tag=zx.bcd_src,distance=0..] run function sweetdream:equipment/sword/blind_candle/dom_one

# ⑨ 清理本轮标记(必须放在 dom_one 之后)
tag @e[tag=zx.bcd_hit,distance=0..] remove zx.bcd_hit
tag @e[tag=zx.bcd_src,distance=0..] remove zx.bcd_src

# ⑩ 表现: 一片烛火燎过去
execute rotated ~ 0 positioned ^ ^ ^2.5 run particle minecraft:flame ~ ~0.5 ~ 2.0 0.4 2.4 0.02 30 normal
execute rotated ~ 0 positioned ^ ^ ^2.5 run particle minecraft:small_flame ~ ~0.6 ~ 1.8 0.4 2.0 0.03 20 normal
playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.8 1.1
playsound minecraft:block.fire.ambient player @a ~ ~ ~ 0.6 1.3

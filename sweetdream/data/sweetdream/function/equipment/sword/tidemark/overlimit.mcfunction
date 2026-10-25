# ============================================================
# sweetdream:equipment/sword/tidemark/overlimit —— 超限·潮痕 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】tidemark/cast ⓪.5(主/副手是 ol:"tidemark" 的潮痕)
# 【文案(超限)】魔力 120 / 冷却 18 秒。
#   "使用后对自身前方 4×5 范围内的生物造成一次相当于自身最大魔力值 ×0.1 的伤害，
#    之后使受到伤害的生物附加「渊海」，若其已有「渊海」则使其「渊海」的持续时间
#    提升至 30 秒。"
# 【和原版的差别】魔力 30→120、冷却 20→18、走廊 4×2→4×5、倍率 0.08→0.1、
#   而且**全部受击者**都上「渊海」(原版只随机挑一个)。
# 【数值改哪】倍率 = 下面 max_mana_mul; 走廊形状/尺寸 = ol_strike 的采样点与半径;
#   门槛(前方有没有人) = ② 的 distance(3.3, 必须盖住整个 4×5 走廊, 见那一行注释);
#   渊海的 30 秒 = ol_apply。
# 【skill 为什么还写 sweetdream:tidemark】观测镜按主手物品的 custom_data.skill 显示
#   冷却; 敲了超限之后原版技能不再使用, 共用一条冷却不会打架(照 liuguang 的做法)。
# ============================================================
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 只读检查: 冷却 + 魔力 120
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:tidemark",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"超限·潮痕冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 120）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ② 前方有没有目标? 没有就整个不放(不扣蓝、不进冷却)
#   走廊 4×5 的最远角在"前方 2 格"球心的 √(2.05² + 2.55²) ≈ 3.27 格处, 所以门槛半径
#   必须 ≥3.3 —— 写成原版那个 ..2 的话, 目标站在走廊**边上/远端**会被判成"前方没人",
#   技能直接不响应(玩家看到的是"明明站着怪却不放")。
#   这里只判"有没有人", 真正打谁由 ol_strike 的 9 个球决定; 半径给大一点最多是
#   "误以为有人"(白扣一次蓝), 给小了是"该放却放不出", 后者更难查。
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..3.3] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..3.3] run return fail

# ③ 扣魔力 -120
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 记冷却 18 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:tidemark",cooldown_seconds:18.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 算伤害: 最大魔力 ×0.1(写进 zx:work tm.dmg, 就是 ol_strike 的宏参数)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work tm.dmg set from storage manacore:out r.damage

# ⑥ 打"前方 4 长 × 5 宽"
function sweetdream:equipment/sword/tidemark/ol_strike with storage zx:work tm

# ⑦ 全部受击者: 没有「渊海」-> 附加; 已有 -> 剩余时长提升至 30 秒
#   ★ 放在打击**之后**: 被这一下打死的自然不在 zx.tm_hit 里了。
execute as @e[tag=zx.tm_hit] at @s run function sweetdream:equipment/sword/tidemark/ol_apply
tag @e[tag=zx.tm_hit,distance=0..] remove zx.tm_hit

# ⑧ 表现
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.9 1.1
execute at @s run playsound minecraft:item.trident.riptide_1 player @a ~ ~ ~ 0.7 1.0

# ============================================================
# sweetdream:equipment/sword/tidemark/cast —— 潮痕 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/tidemark(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 30 / 冷却 20 秒。
#   "使用后对自身前方 4×2 范围内的生物造成一次相当于自身最大魔力值 ×0.08 的
#    伤害，之后使受到伤害的随机一个生物附加「渊海」。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: "自身前方 4×2 范围" -> 一条 4 格长 × 2 格宽 的走廊
#      (2 个采样点: 前向 1.0 / 3.0 各半径 1.0 —— 合起来 0~4 格长、±1 格宽 = 2 宽)。
#      ★ 口径待用户确认: 原文写 "4×2" 未标"长×宽"; 这里取 **4 格长 × 2 格宽**
#        (与前缀"前方"读法一致)。若本意是"4 宽 × 2 长", 改 strike 的两个采样点即可。
#   ③ 次数: 1 次。
#   ④ 时长: —(瞬发)。
# 【伤害口径】最大魔力 ×0.08 -> max_mana_mul 通道。
# 【数值改哪】倍率 0.08 = 下面的 max_mana_mul; 走廊形状 = strike 的采样点/半径;
#   走廊有无目标的门槛 = 下面 positioned ^ ^ ^2 的 distance=..2; 随机附加 = 末尾那行。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/tidemark

# ⓪.5 【超限分流】(2026-10-23 批 K1) 敲过超限石(ol:"tidemark")的潮痕, 右键放的是
#      「超限·潮痕」: 120 蓝 / 18 秒 / 前方 4×5 / 最大魔力 ×0.1 / 全体附「渊海」。
#   ★ 主副手都判, 而且判 ol 的**值**是不是 tidemark —— 只判 .ol 键在不在的话,
#     副手拿着别的超限武器会误走超限分支(照 liuguang/cast ⓪.5 那一课)。
scoreboard players set #tm_ol zx.meta 0
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["tidemark"],ol:"tidemark"}] run scoreboard players set #tm_ol zx.meta 1
execute if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["tidemark"],ol:"tidemark"}] run scoreboard players set #tm_ol zx.meta 1
execute if score #tm_ol zx.meta matches 1 run function sweetdream:equipment/sword/tidemark/overlimit
execute if score #tm_ol zx.meta matches 1 run return 0

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 30
#   【skill 不能漏】api/skill/check 是"有 skill 才查冷却"; 漏了它 out.success 不会翻 1b。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:tidemark",mana:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"潮痕冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 30）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 前方有目标吗? 没有就整个不放(不扣蓝、不进冷却)
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2] run return fail

# ④ 扣魔力 -30
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 20 秒
#   ★ 2026-10-12 修坑 120 的姊妹条: 冷却时长走框架真实时长, 不要自己 tick 递减。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:tidemark",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 算伤害: 最大魔力 ×0.08(写进 zx:work tm.dmg, 就是 strike 的宏参数)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work tm.dmg set from storage manacore:out r.damage

# ⑦ 打"前方 4 长 × 2 宽"
function sweetdream:equipment/sword/tidemark/strike with storage zx:work tm

# ⑧ 使受到伤害的随机一个生物附加「渊海」
#   ★ 必须在 strike **之后**: 此刻 zx.tm_hit 才是"这一发打到的那批"。
#   ★ sort=random 从这批里随机挑一只; 没有命中者时该行自然不跑。
#   ★ tag/mark 只对非玩家活体贴, 玩家本就进不了 no_damage 名单外的选择器 —— 不冲突。
execute as @e[tag=zx.tm_hit,limit=1,sort=random] at @s run function sweetdream:tag/mark {target:"@s",mark:"yuanhai"}
# 收尾: 清本轮命中标记, 不留残余
tag @e[tag=zx.tm_hit,distance=0..] remove zx.tm_hit

# ⑨ 表现: 一道潮痕水光
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.9 1.3
execute at @s run playsound minecraft:item.trident.riptide_1 player @a ~ ~ ~ 0.6 1.2

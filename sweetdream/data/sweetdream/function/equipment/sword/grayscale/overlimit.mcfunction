# ============================================================
# sweetdream:equipment/sword/grayscale/overlimit —— 超限·灰度 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】grayscale/cast ⓪.5(主/副手是 ol:"grayscale" 的灰度)
# 【文案(超限)】魔力 120 / 冷却 12 秒。
#   "使用后使自身 5 格内的生物受到一次相当于自身最大魔力值 ×0.1 的伤害，之后使其
#    燃烧 3 秒。若已经处于燃烧状态则改为使其附加「流火」并额外附加一次相当于自身
#    最大魔力值 x0.08 的真实伤害。"
# 【和原版的差别】魔力 30→120、冷却 18→12、半径 2→5、基数 当前魔力×0.08 → **最大魔力**×0.1、
#   已燃烧的目标额外吃一发最大魔力 ×0.08 的真伤。
# 【★ 基数换通道 ★】原版走 other_mul(基数 = 面板当前魔力); 超限必须走 max_mana_mul,
#   否则"当前魔力"在扣费后变小、伤害跟着飘。物品 tags 也同步把 cur_mana 换成
#   max_mana(见 station/api/apply_go ②.4b), 那是给标签体系看的语义, 两者要一致。
# 【两次 calc】主伤(×0.1)和真伤(×0.08)各算一次 —— 真伤不吃主伤的乘区, 也不能
#   拿同一个 r.damage 去乘(样板: "固定伤害不参与乘区 ⇒ 两次 calc")。
# 【存储键为什么叫 gso 而不是 gs】zx:work gs 是**钩丝(gousi)**在用的键(cast/pull_go 里 `set value {own:0}` 会整段覆盖),
#   两件武器同一个玩家身上不会同时施法, 但"先拉人再切刀"是可能的 —— 撞键就是真伤静默变 0。
# 【谁算"已经在烧"】ol_mark_burn 在主伤**之前**判 Fire, 打上 zx.gs_burn; 主伤之后
#   再按这个标签打真伤 —— 死掉的目标自然从选择器里消失, 不会给尸体补刀。
# ============================================================
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 只读检查: 冷却 + 魔力 120
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grayscale",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"超限·灰度冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 120）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ② 自身 5 格内有目标吗? 没有就不放(不扣蓝、不进冷却)
execute unless entity @e[type=!#sweetdream:no_damage,distance=..5] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=..5] run return fail

# ③ 扣魔力 -120
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 记冷却 12 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grayscale",cooldown_seconds:12.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 主伤: 最大魔力 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work gso.dmg set from storage manacore:out r.damage

# ⑤.5 真伤: 最大魔力 ×0.08(独立算一次, 不继承主伤的任何乘区)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work gso.td set from storage manacore:out r.damage

# ⑥ 圈定"自身 5 格内", 并把"此刻已经在烧"的单独标出来(必须在主伤之前判)
tag @e[tag=zx.gs_hit,distance=0..] remove zx.gs_hit
tag @e[tag=zx.gs_burn,distance=0..] remove zx.gs_burn
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.gs_hit
execute as @e[tag=zx.gs_hit] at @s run function sweetdream:equipment/sword/grayscale/ol_mark_burn

# ⑦ 主伤打出去
data modify storage zx:in arg set value {target:"@e[tag=zx.gs_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work gso.dmg
execute at @s run function sweetdream:api/damage

# ⑧ 已燃烧的那批: 额外一发真伤
data modify storage zx:in arg set value {target:"@e[tag=zx.gs_burn,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage zx:work gso.td
execute at @s run function sweetdream:api/damage

# ⑨ 逐只: 没在烧 -> 燃烧 3 秒; 已在烧 -> 附加「流火」
#   状态判据和效果都复用原版 apply(超限没改这一条), 不另写一份。
#   ★ 放在伤害**之后**: 被这一下打死的自然不在 zx.gs_hit 里了, 不会给尸体点火。
execute as @e[tag=zx.gs_hit] at @s run function sweetdream:equipment/sword/grayscale/apply

tag @e[tag=zx.gs_hit,distance=0..] remove zx.gs_hit
tag @e[tag=zx.gs_burn,distance=0..] remove zx.gs_burn

# ⑩ 表现: 一圈更大的灰雾
execute at @s run particle minecraft:smoke ~ ~1 ~ 2.6 1.2 2.6 0.04 60 normal
execute at @s run particle minecraft:ash ~ ~1 ~ 2.6 1.2 2.6 0.03 45 normal
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.8 0.6

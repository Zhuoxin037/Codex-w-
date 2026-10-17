# ============================================================
# sweetdream:equipment/staff/wake_bell/skill —— 醒梦钟 · 主动技能(潜行右键)
# ------------------------------------------------------------
# 【谁调用它】cast ①(潜行)   【执行者】施法者
# 【技能原文】
#   ✦ 主动技能   魔力 400 · 冷却 70 秒
#   "使用后消耗自身 8 格内最多 3 个生物的「白昼梦」，并对其造成一次相当于自身最大
#    魔力值 ×0.1 的真实伤害。"
# 【★ 四要素 ★】
#   ① 触发: 潜行右键。
#   ② 范围: 自身 8 格内; 最多 3 个(sort=nearest, limit=3)。
#   ③ 次数: 一段。
#   ④ 时长: 无(纯瞬间)。
# 【★ 伤害类型 = 真实伤害 ★】sweetdream:true_damage(无视护甲)。
# 【★ "消耗…并对其造成" ⇒ 只打真被消耗掉的那几只 ★】
#   mark_consume 支持**范围选择器**: 内部 execute as 逐个判有没有标签、逐个摘。
#   于是"真消耗掉的" = 现在**不再带** zx.status.dream 的那些;
#   穿「永恒」被补回来的仍带着 dream ⇒ 那几只不打(没有真的消耗)。
# 【★ 为什么不用 mc.ok 判 ★】范围调用时 mc.ok 只反映"最后一个"目标, 代表不了整批。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 400
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wake_bell",mana:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"醒梦钟冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 400）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 8 格内有没有带「白昼梦」的? 一只都没有就整个不放(不白扣蓝)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8,tag=zx.status.dream] run tellraw @s [{"text":"附近没有附有「白昼梦」的生物","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8,tag=zx.status.dream] run return fail

# ④ 扣魔力 -400
data modify storage manacore:in arg set value {uuid:"",value:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 70 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wake_bell",cooldown_seconds:70.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 钉住 8 格内最多 3 个带「白昼梦」的(就近)
tag @e[tag=zx.wb_tgt,distance=0..] remove zx.wb_tgt
tag @e[tag=zx.wb_ok,distance=0..] remove zx.wb_ok
execute as @e[type=!#sweetdream:no_damage,distance=0.1..8,tag=zx.status.dream,sort=nearest,limit=3] run tag @s add zx.wb_tgt

# ⑦ 一次性消耗这批的「白昼梦」
#   ★ 执行者是**施法者本人**(余烬只认 @s); 目标走选择器字符串传给 mark_consume,
#     它在内部用 mc_check 逐个 as/摘, 不会换掉这里的身份。
data modify storage zx:work a set value {target:"@e[tag=zx.wb_tgt,distance=0..]",mark:"dream"}
function sweetdream:lib/mark_consume

# ⑧ 真被消耗掉的 = 现在不再带 dream 的
execute as @e[tag=zx.wb_tgt,distance=0..] unless entity @s[tag=zx.status.dream] run tag @s add zx.wb_ok
execute unless entity @e[tag=zx.wb_ok,distance=0..,limit=1] run tag @e[tag=zx.wb_tgt,distance=0..] remove zx.wb_tgt
execute unless entity @e[tag=zx.wb_ok,distance=0..,limit=1] run return 0

# ⑨ 真实伤害 = 最大魔力值 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.wb_ok,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ⑩ 表现 + 清理
execute at @e[tag=zx.wb_ok,distance=0..,limit=1] run particle minecraft:witch ~ ~1 ~ 0.6 0.8 0.6 0.05 30 normal
execute at @e[tag=zx.wb_ok,distance=0..,limit=1] run particle minecraft:soul ~ ~1 ~ 0.4 0.6 0.4 0.02 16 normal
playsound minecraft:block.bell.use player @a ~ ~ ~ 1.0 0.7
playsound minecraft:block.conduit.attack.target player @a ~ ~ ~ 0.7 1.2

tag @e[tag=zx.wb_tgt,distance=0..] remove zx.wb_tgt
tag @e[tag=zx.wb_ok,distance=0..] remove zx.wb_ok

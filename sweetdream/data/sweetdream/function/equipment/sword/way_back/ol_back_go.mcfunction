# ============================================================
# sweetdream:equipment/sword/way_back/ol_back_go —— 超限·归途 的宏件
# ------------------------------------------------------------
# 【宏参数】zx:work owner_arg {uuid} —— 施法者 UUID 文本(灯 marker 的 tag 后缀)
# 【执行者】玩家本人
# 【本文件为什么是宏】三处要用 uuid 拼 tag/选择器：找灯、给灯挂 zx.wb_tgt、摘灯标签。
# ============================================================

# ⓪ 灯还在吗(跨维度 / 被清掉 -> 走原版 lost: 状态清空, 不给任何返还)
$execute unless entity @e[type=marker,tag=zx.wb_lamp_$(uuid)] run return run function sweetdream:equipment/sword/way_back/lost

# ① 返还 100%
#   zx.wb_dmg 是 ×1000 的"累计受伤"(见 on_hurt / lib/hurt_gain 的口径) => ÷1000 得整点。
#   ★ 原版这里还有 `/2`(50%) 与"夹到最大生命 40%" 两段, 超限全删 —— 文案没写上限。
#   ★ #heal_got 先手动清零: 万一这一轮不治疗(伤害累加为 0),
#     lib/heal 不会跑、出参就还是上一轮的旧值, 后面的真伤会凭空多打一发。
scoreboard players set #heal_got zx.meta 0
scoreboard players operation #wb_h zx.meta = @s zx.wb_dmg
scoreboard players operation #wb_h zx.meta /= #1000 zx.meta
scoreboard players set #heal_pt zx.meta 0
execute if score #wb_h zx.meta matches 1.. run scoreboard players operation #heal_pt zx.meta = #wb_h zx.meta
execute if score #wb_h zx.meta matches 1.. run function sweetdream:lib/heal

# ② 连线真伤: 玩家**原**位置 → 归途灯
#   ★ 这一整段必须排在"瞬移"之前 ★ 瞬移之后再算, 起点已经变成灯的位置, 连线长度为 0。
#   ★ ol_line 只认 zx.wb_tgt 这一个标签(不带 uuid), 所以先给灯挂上、扫完再摘 ——
#     这样自递归里不用每一步都展开一次宏(宏展开是整行重解析, 递归里成本很高)。
tag @e[tag=zx.wb_line,distance=0..] remove zx.wb_line
$tag @e[type=marker,tag=zx.wb_lamp_$(uuid),limit=1] add zx.wb_tgt
scoreboard players set #wb_step zx.meta 0
execute at @s facing entity @e[tag=zx.wb_tgt,limit=1] feet run function sweetdream:equipment/sword/way_back/ol_line
$tag @e[type=marker,tag=zx.wb_lamp_$(uuid),limit=1] remove zx.wb_tgt

#   数值 = 本次实际回复量; 0 就一条都不打(也不留空选择器给 api/damage)
data modify storage zx:in arg set value {target:"@e[tag=zx.wb_line,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
execute if score #heal_got zx.meta matches 1.. store result storage zx:in arg.damage double 1 run scoreboard players get #heal_got zx.meta
execute if score #heal_got zx.meta matches 1.. at @s run function sweetdream:api/damage
tag @e[tag=zx.wb_line,distance=0..] remove zx.wb_line

# ③ 瞬移回灯
data modify storage zx:work owner_arg set from storage zx:data self
function sweetdream:equipment/sword/way_back/teleport with storage zx:work owner_arg

# ④ 增益: 10 秒迅捷Ⅱ + 5 秒抗性提升Ⅲ(无条件)
#   ★ 药水等级参数是"放大器"而不是"等级": Ⅱ 要写 1、Ⅲ 要写 2。
effect give @s minecraft:speed 10 1 true
effect give @s minecraft:resistance 5 2 true

# ⑤ 表现(此刻 @s 已经在灯的位置, 所以粒子落在灯上)
playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.9 1.1
particle minecraft:portal ~ ~1 ~ 0.5 0.8 0.5 0.5 40 normal

# ⑥ 收尾: 清状态 + 杀灯(与原版同一条 end)
function sweetdream:equipment/sword/way_back/end

# ============================================================
# sweetdream:equipment/liuguang/damage —— 流光技能主流程
# ------------------------------------------------------------
# 【用法】以玩家身份执行 /function sweetdream:equipment/liuguang/damage
# 【流程】
#   ① 拿 UUID
#   ② 只读检查(冷却 + 魔力) —— 不产生副作用, 只用来给提示
#   ③ 扣魔力(要么全扣要么不扣)
#   ④ 记冷却(扣蓝成功之后才记)
#   ⑤ 算伤害 -> 交给 effect 打出去
#   ⑥ 反馈
# 【冷却是怎么接进来的】前置包把冷却按"玩家 + 技能 id"两个键存, 于是:
#   - 多个技能能同时冷却, 每个玩家各自独立(天生多人兼容)
#   - 同一把刀换个人拿, 冷却互不影响
#   技能 id 用 "sweetdream:liuguang"; 以后做别的技能, 只改这一个字符串即可。
# 【顺序为什么是 check -> consume -> start】任何一步失败都不留副作用,
#   不会出现"技能没放出去蓝却没了", 也不会"技能没成功还进了冷却"。
# 【这里修掉的两处】
#   ① 原来写的是 ... with storage manacore:out r.damage
#      宏参数必须是一个复合标签(对象)。r.damage 是单个 double,
#      传进去会报错, 结果 effect 这个函数压根不会被调用。
#      改成传整个 r, 它里面的每个键都会成为宏变量。
#   ② 原来的选择器用了 #manacore:no_damage 这个实体类型标签。
#      manacore 包里并没有定义它(那里只有函数标签 function/event),
#      标签不存在 -> 选择器解析失败 -> 整条命令报错 -> 没有伤害。
#      改用本包自己的 #sweetdream:no_damage(在 tags/entity_type/no_damage.json)。
#   顺带把 target / type 从"给 calc 的参数"里挪走了: calc 只算伤害,
#   不认识 target, 打谁由 effect 那一步决定。
# ============================================================

# ① 先拿 uuid, 拿不到就直接结束, 不往下走
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力够不够(不扣蓝、不进冷却, 可以随便调)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liuguang",mana:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"流光冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 15)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 锁定目标: 附近没有能打的东西就不放技能
#   【为什么放在扣蓝之前】这一步没有任何副作用。放这里意味着"没目标"时
#     既不扣魔力、也不进冷却、也不造成伤害 —— 只是白白提示一句。
#   【distance=0.1..3 的下界 0.1 是干嘛的】自己到自己的距离是 0, 所以从 0.1
#     起步就把"自己"排除掉了。不加这一条的话, 选择器永远至少选中你自己:
#     检查形同虚设, 而且打伤害时会把你自己也打一顿。
#   【要改范围】这里和 effect 里那行打伤害的选择器必须一起改。
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..3] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..3] run return fail

# ④ 扣魔力(要么全扣要么一点不扣)
data modify storage manacore:in arg set value {uuid:"",value:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却: 20 秒, 默认吃玩家的"冷却缩减"属性
#    不想让这个技能吃缩减就加 reduce:0b
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liuguang",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 顺手记下"最近放过的技能", 给观测镜面板显示冷却用。
# 框架的 #manacore:event/cooldown_start 里也挂了一份(见 sweetdream:event/cooldown_start),
# 这里是双保险: 万一事件没触发, 面板照样有数可看。
data modify storage zx:work a.uuid set from storage zx:data self.uuid
data modify storage zx:work a.skill set value "sweetdream:liuguang"
function sweetdream:event/cooldown_start_go with storage zx:work a

# ⑥ 算伤害(只算不打, 结果落在 manacore:out r.damage)
data modify storage manacore:in arg set value {uuid:"",skill_multiplier:5.0,custom_damage:0.0,independent_multiplier:1.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ⑦ 把 manacore:out 抄进工作节点, 再补上自己的 uuid, 一起交给 effect
#    注1: out r.remaining 这时还留着第⑤步(记冷却)写进去的冷却时长(calc 不会动它)
#    注2: 为什么要多带一个 uuid —— effect 要用它去查 u0..u3, 拼出"只指向我"的
#         选择器当 /damage 的攻击者, 这样击杀才记在你头上。
data modify storage zx:work a set from storage manacore:out r
data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:equipment/liuguang/effect with storage zx:work a

# ⑧ 反馈: 伤害 + 这次进了多长冷却
tellraw @s [{"text":"伤害: ","color":"gray"},{"nbt":"r.damage","storage":"manacore:out","color":"gold"},{"text":"   冷却: ","color":"gray"},{"nbt":"r.remaining","storage":"manacore:out","color":"aqua"},{"text":" tick","color":"gray"}]

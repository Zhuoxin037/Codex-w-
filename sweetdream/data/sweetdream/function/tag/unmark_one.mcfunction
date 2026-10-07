# @s = 单只目标。先验证名称；非法输入不能修改状态或生成显示实体。
$data modify storage zx:tag request set value {mark:"$(mark)"}
execute unless data storage zx:tag request{mark:"yuanhai"} unless data storage zx:tag request{mark:"liuhuo"} unless data storage zx:tag request{mark:"yehuo"} unless data storage zx:tag request{mark:"shixin"} unless data storage zx:tag request{mark:"dream"} run return 0
execute unless entity @s[tag=zx.tags_v2] run function sweetdream:tag/migrate

# ---- 撤销"施加时挂上的效果" ----
#   这里是**唯一**的撤销点: TTL 到期(tag/ttl_tick)、被武器消耗
#   (lib/mark_consume -> tag/unmark)、调试摘标签, 三条路最终都进本函数。
#   ★ 属性修饰符是**实体数据**: 不撤就永久生效(护甲 -20% / 攻击力 -20%), 且不报错。
#   ★ 判据用 zx:tag request(第一行刚写的 mark)而不是"标签还在不在" —— 保证
#     只要摘标签就一定顺手撤销, 不会因为标签先被别的路径摘掉而漏撤。
#   ★ `modifier remove` 对不存在的 id 是空操作, 不必先判存在。
execute if data storage zx:tag request{mark:"liuhuo"} run attribute @s minecraft:armor modifier remove sweetdream:tag_liuhuo
execute if data storage zx:tag request{mark:"dream"} run attribute @s minecraft:attack_damage modifier remove sweetdream:tag_dream_atk

# ---- 清掉剩余秒数(免得残留分数被下一次 ttl 检查误判成"还剩几秒") ----
execute if data storage zx:tag request{mark:"yuanhai"} run scoreboard players reset @s zx.tt.yuanhai
execute if data storage zx:tag request{mark:"liuhuo"} run scoreboard players reset @s zx.tt.liuhuo
execute if data storage zx:tag request{mark:"yehuo"} run scoreboard players reset @s zx.tt.yehuo
execute if data storage zx:tag request{mark:"shixin"} run scoreboard players reset @s zx.tt.shixin
execute if data storage zx:tag request{mark:"dream"} run scoreboard players reset @s zx.tt.dream

$tag @s remove zx.status.$(mark)
function sweetdream:tag/icon_refresh
